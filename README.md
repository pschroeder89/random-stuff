# Random Stuff
Just some scripts or snippets for various things

### Contains:

##### time_machine_script.sh
   
   **Context:**
   
   After building a test metric framework, we needed a way to historically run our script and capture metric stats on a weekly basis since a project's inception. 
   
   **Usage:**
   
   To get the number of characters in this README at every minute since the initial commit of this repo, run:
   
        `COMMAND='wc -c README.md' INTERVAL=minute sh time_machine_script.sh`
        
   Example output:
```
        Determining first commit epoch time
        Determining current epoch time
        Running command: wc -c README.md
              64 README.md
              64 README.md
              64 README.md
              98 README.md
             174 README.md
             174 README.md
             174 README.md
             174 README.md
             641 README.md
             845 README.md

```
