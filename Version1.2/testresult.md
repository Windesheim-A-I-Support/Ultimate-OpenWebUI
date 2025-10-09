When trying to load a local model; it does download it from ollama but it responds with error 500: llama runner process has terminated

When switching model, if there was an error (e.g a local model selected) the chat can no longer continue (Might not be fixable)

Deepseek: R1 provider (Free) Doesnt work? Provider returned error
(I didnt have a deepseek api key tho, can you use that for free?)

The test TC-004-003 is completed successfully if we use openrouter models
OpenAI: Gpt-oss-20B (free)
Quen: Quen3 4B (free)

TC-004-004 Completed successfully; with OpenAI: Gpt-oss-20B (free)

TC-004-005 completed successfully

TC-004-006 completed sucessfully
JSON PDF and TXT
Deletion works
Archival works

TC-004-007 
Works Quen responds with Arr you're a pirate

TC-005-001 completed successfully
Chats still there when restarted
curl -s http://localhost:6333/healthz
healthz check passed

TC-005-003 
team1-faster-whisper   Up 35 hours (unhealthy)
team1-openwebui        Up 3 minutes (healthy)
team1-litellm          Up 43 hours (unhealthy)
team1-searxng          Up 43 hours (healthy)
team1-redis            Up 43 hours (healthy)
team1-qdrant           Up 2 days (healthy)
team1-tika             Up 2 days (healthy)
team1-pipelines        Up 2 days (healthy)
team1-jupyter          Up 43 hours (healthy)
team1-watchtower       Up 2 days (healthy)
team1-mcpo             Up 43 hours (healthy)
team1-ollama           Up 43 hours (healthy)
team1-postgres         Up 43 hours (healthy)
root@Production-OpenWebTeam1:~# 


TC-005-004 Half-pass?
chat backup works
Users work
However, download databases does not because "this feature is only availble for SQLite databases"

TC-005-005
drwxr-xr-x 2 root root  3 Oct  3 19:33 .
drwxr-xr-x 4 root root  4 Sep 25 17:57 ..
-rw-r--r-- 1 root root 50 Oct  3 19:33 test-file.txt
File was successfully removed

TC-006-001 FAILURE
Uploading document does take quite long...
Errors, went so fast coudnt read it
Try a smaller file.
338 KB pdf
Warning:
List index out of range..
asking about the file, it cannot find it.

trying knowledgebase upload
warning intex out of range
FAILED TO ADD FILE

since a lot of the other test depend on it, I think its best to stop here.
