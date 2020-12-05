import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os, sys
from os import path
from nltk.corpus import wordnet as wn
from nltk.tag import pos_tag


#constructs and holds a matrix that describes the similarity between words
class Word_Similarity:
    
    def __init__(self):
        
        #Similarity[i,j] = the similarity between labels with indicies i and j
        self.Similarity_Matrix = None
                
        #a meanings dictionary can be manually filled to "define" colloquial labels 
        #Ex: "besties" -> best_friends
        #besties cannot be found in the Wordnet corpus, but best_friends can
        self.Meanings_Dict = None
        
        #file system navigation variables
        csvs_directory = os.path.join(os.getcwd(),"..","misc")
        self.similarity_csv_path = os.path.join(csvs_directory,"similarity_matrix.csv")
        self.meanings_csv_path = os.path.join(csvs_directory,"meanings.csv")
       
        
    #caller can also specify that matrix should be rebuilt. (in some cases, this will happen automatically)
    def load_Similarity_Matrix(self,labels=None,force_rebuild=False):        
               
        #try to load the structures from disk
        if path.exists(self.similarity_csv_path):
            self.Similarity_Matrix = pd.read_csv(self.similarity_csv_path)
        if path.exists(self.meanings_csv_path):
            Meanings_df = pd.read_csv(self.meanings_csv_path,header=None,index_col=0).dropna()
            Meanings_Dict = {label : Meanings_df.loc[label][1] for label in Meanings_df.index.values}
            if (self.Meanings_Dict is not None) and (self.Meanings_Dict != Meanings_Dict):
                print("Meanings Dictionary has been updated on disk.")
                force_rebuild = True
            self.Meanings_Dict = Meanings_Dict
                
        #check for input inconsistencies
        if (labels is None) and (self.Similarity_Matrix is None) and (self.Meanings_Dict is None):
            print("FATAL ERROR: no labels were provided and meanings.csv could not be found, so no way to infer labels")
            return
        elif (labels is not None) and (self.Meanings_Dict is not None) and (set(labels) != set(self.Meanings_Dict.keys())):
            print("FATAL ERROR: Provided labels and meanings.csv do not match! Either delete meanings.csv or pass labels=None.")
            return
        elif (labels is not None) and (self.Similarity_Matrix is not None) and (set(labels) != set(self.Similarity_Matrix.index)):
            print("Provided Labels more recent than Similarity_Matrix indices.")
            force_rebuild = True
        elif (self.Meanings_Dict is not None) and (self.Similarity_Matrix is not None) and (set(self.Meanings_Dict.keys()) != set(self.Similarity_Matrix.index)):
            print("Meanings Dictionary Keys more recent than Similarity_Matrix indices.")
            force_rebuild = True

            
        #if the rebuild is not forced, we can simply read self.Similarity_Matrix from disk!
        if (not force_rebuild) and (self.Similarity_Matrix is not None):
          if(self.Meanings_Dict is None):
              print("Rebuilding Meanings Dictionary using Similarity Matrix from disk...")
              labels = self.Similarity_Matrix.index
              Meanings_df = pd.DataFrame(data=labels,index=labels)
              Meanings_df.to_csv(self.meanings_csv_path,header=False,index_label=False)
              self.Meanings_Dict = {label : Meanings_df.loc[label][0] for label in Meanings_df.index.values}
              print("Meanings Dictionary successfully saved to file.")
          print("All structures successfully loaded!")
          return
        
        #otherwise self.Similarity_Matrix will have to be re-computed
        
        #see if dictionary already exists on disk
        if (self.Meanings_Dict is not None):
            print("Meanings Dictionary successfully loaded from file.")
            labels = list(self.Meanings_Dict.keys())
        elif (labels is not None):         
            print("Building default Meanings Dictionary from labels...")
            Meanings_df = pd.DataFrame(data=labels,index=labels)
            Meanings_df.to_csv(self.meanings_csv_path,header=False,index_label=False)
            self.Meanings_Dict = {label : Meanings_df.loc[label][0] for label in Meanings_df.index.values}
            print("Meanings Dictionary successfully saved to file.")
        else:
            print("FATAL ERROR: no labels were provided and meanings.csv could not be found, so no way to infer labels")
            return 
                           
        #build the similarity matrix
        print("Updating Similarity_Matrix...")
        self.__build_Similarity_Matrix(labels)
        print("Similarity Matrix successfully built.")
        
        #save self.Similarity_Matrix to a csv
        self.Similarity_Matrix.to_csv(self.similarity_csv_path,header=True,index_label=False)
        print("Similarity Matrix successfully saved to file.")
        
            
    #converts a word (string) to a Wordnet object (synset)
    def word2synset(self,word):
        synsets = wn.synsets(word)
        #word AND no related synset found
        if( len(synsets) == 0 ):
            return None
        #the first entry in synsets is not always the synset corresponding to word
        synset = None
        for s in synsets:
            if word.lower() == s.lemmas()[0].name().lower():
                synset = s
                break
        #none found choose the next best synset
        if synset is None:
            return synsets[0]
        else:
            return synset
    
    #returns the similarity between two words as defined by WordNet::path_similarity()
    def __get_similarity(self,word1,word2):
        synset1 = self.word2synset(word1)
        synset2 = self.word2synset(word2)
        if (synset1 is not None) and (synset2 is not None) :
            similarity = synset1.path_similarity(synset2)
            if (similarity is not None) :
                return similarity
        return 0
        
    #private so meaning_Dict is initialized before this is called
    def __build_Similarity_Matrix(self,labels):
        
        #initialize matrix with zeros
        dim = len(labels)
        self.Similarity_Matrix = pd.DataFrame(data = np.zeros((dim,dim)), index = labels, columns = labels)
       
        #fill matrix
        for i in range(dim):
            label_i_meaning = self.Meanings_Dict[labels[i]]
            for j in range(i,dim):
                similarity = 0.0
                if i != j :
                    label_j_meaning = self.Meanings_Dict[labels[j]]
                    similarity = self.__get_similarity(  label_i_meaning  ,  label_j_meaning  )
                self.Similarity_Matrix.iloc[i,j] = self.Similarity_Matrix.iloc[j,i] = similarity  
                
    #returns a matrix R where R[i,j]=1 if Similarity[i,j] > Threshold
    #if Threshold is unspecified, returns the Similarity Matrix
    def get_Similarity_Matrix(self,threshold=None):
        if threshold == None:
            return self.Similarity_Matrix
        else:
            return (self.Similarity_Matrix >= threshold).astype('int32')
    
    
#balances data by substituted common tags with 
class Data_Balance:
    
    def __init__(self):
        self.X_df = None
        self.Balanced_X_df = None
    
    def load_X_df(self,X_df):
        self.X_df = X_df
        self.Balanced_X_df = X_df.copy(deep=True)
        
    #returns variance in probability of observing each label
    def get_variance(self,df):
        return (df.sum(axis=0) / df.shape[0]).var()
    
    #plot the probability of probability of observing each label, the variance, and 5 most common labels
    def visualize_pdf(self,df):
        fig = plt.figure()
        ax = fig.add_axes([0,0,1,1])
        ax.set_title('Frequency of each Label')
        ax.set_ylabel('Frequency (# observations per image)')
        ax.set_xlabel('Labels Index')
        row_index = np.arange(0,df.shape[1])
        label_pdf = (df.sum(axis=0) / df.shape[0])
        ax.bar(row_index , label_pdf)
        plt.show()
        print("Variance in Frequency:",self.get_variance(df))
        print("5 Most Common Labels:",[(label,label_pdf.loc[label]) for label in label_pdf.nlargest(n=5).index.values])
        print("5 Least Common Labels:",[(label,label_pdf.loc[label]) for label in label_pdf.nsmallest(n=5).index.values])

    #for columns in Balanced_X_df that are not in M, these columns are removed from self.Balanced_X_df
    #for columns in M that are not in Balanced_X_df, these columns are added to self.Balanced_X_df as columns of zeros
    def __align_to_Matrix(self,M):
        cols_to_drop =  set(self.Balanced_X_df.columns) - set(M.columns)
        cols_unique_to_M = set(M.columns) - set(self.Balanced_X_df.columns)
              
        if len(cols_to_drop) != 0:
            print("Removing columns",cols_to_drop)
        if len(cols_unique_to_M) != 0:
            print("Adding columns:",cols_unique_to_M)
            
        #zeros_col = np.zeros(self.Balanced_X_df.shape[0])
        self.Balanced_X_df = self.Balanced_X_df.drop(cols_to_drop) #rid of columns unique to Balance_X_df
        self.Balanced_X_df.loc[:,cols_unique_to_M] = 0 #add new columns as zero columns
        
 
    #df: dataframe of 1s and 0s
    #remove_series: pd.Series
    #returns df with x random 1s removed from column i, where x is the ith element of remove_series. 
    #If prevent_zero_rows is true, a 1 will not be removed if it is the last 1 in its row
    def __remove_ones(self,df,remove_series,prevent_zero_rows=False) :
        for i in range(0,df.shape[1]):
            num_ones_to_remove = remove_series[i]
            if(num_ones_to_remove == 0):
                continue
            col = df.iloc[:,i]
            if prevent_zero_rows:
                col *= (df.sum(axis=1) - 1) # 0 out rows with only 1 label left
            ones_indicies = col[col >= 1].index.to_numpy()
            num_ones_to_remove = min(ones_indicies.shape[0],num_ones_to_remove)
            ones_indicies_to_remove = np.random.choice(ones_indicies,num_ones_to_remove,replace=False)
            df.iloc[ones_indicies_to_remove,i] = 0
        return df
    
       
    #substitute common labels for uncommon labels with similar meaning
    #similar meaning is determined by the Similarity_Matrix. I and J are similar iff Similarity_Matrix[i][j] == 1
    #this process is repeated ITERATIONS times, but note that ITERATIONS != 1 is not recomended 
    def balance_data(self,Similarity_Matrix,ITERATIONS=1):
        
        #align labels of Balanced_X_df with those of similarity matrix
        self.__align_to_Matrix(Similarity_Matrix)
        
        #setup structures for loop
        index = self.Balanced_X_df.index
        columns = self.Balanced_X_df.columns
        frequency_dict = pd.DataFrame(self.Balanced_X_df.sum(axis=0))
        av_freq = frequency_dict.mean(axis=0)[0]
        
        #performs numpy (w broadcasting) multiplication on df1 and df2 returning a new dataframe with index,columns of df3
        multiply_positional_index = lambda df1,df2,df3 : pd.DataFrame(data=(df1.to_numpy() * df2.to_numpy()), index=df3.index, columns=df3.columns)
        
        #print current variance
        print("Starting Variance:",self.get_variance(self.Balanced_X_df))
        
        #use similarity to perform substitutions that lower data imbalance
        for i in range(ITERATIONS):
        
            #create a matrix of allowed substitutions (1 if Label I -> Label J allowed, else 0)
            underrepresented_dict = (1.0 * (frequency_dict < av_freq)).transpose()
            substitutions_df = multiply_positional_index(Similarity_Matrix, underrepresented_dict, Similarity_Matrix)
        
            #perform substitutions:
            update_df = self.Balanced_X_df.dot(substitutions_df).astype('int32')
        
            #remove some substituted tags from update_df that are now over-represented
            counts_obtained = update_df.sum(axis=0)
            counts_needed = (((av_freq - frequency_dict) > 0) * (av_freq - frequency_dict)).iloc[:,0]
            remove_series = (((counts_obtained - counts_needed) > 0) * (counts_obtained - counts_needed)).astype('int32')
            update_df = self.__remove_ones(update_df,remove_series,prevent_zero_rows=False).astype('int32')
        
            #remove some overrepresented tags that were substituted
            counts_to_remove = (((frequency_dict - av_freq) > 0) * (frequency_dict - av_freq)).iloc[:,0]
            #dont reduce counts of labels with no substitutions
            labels_with_substitutions = (substitutions_df.sum(axis=1) >= 1)
            remove_series = (counts_to_remove * labels_with_substitutions).astype('int32')
            self.Balanced_X_df = self.__remove_ones(self.Balanced_X_df,remove_series,prevent_zero_rows=True).astype('int32')
        
            #update dataframe and calculate new frequencies
            self.Balanced_X_df = pd.DataFrame(data=np.logical_or(self.Balanced_X_df , update_df) ,index=index, columns=columns).astype('int32')
            frequency_dict = pd.DataFrame(self.Balanced_X_df.sum(axis=0))
            av_freq = frequency_dict.mean(axis=0)[0]
        
        print("Completed",ITERATIONS,"iterations! | Ending Variance:",self.get_variance(self.Balanced_X_df))
                
                
       
    