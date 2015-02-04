echo "Indexing anonymized weblog data"
es_host="http://localhost:9200"
es_index="mylogs"
curl -X DELETE "$es_host/mylogs"
curl -XPOST    "$es_host/mylogs" -d '
{
   "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0,
      "analysis": {
         "analyzer": {
            "ip4_analyzer": {
               "tokenizer": "ip4_hierarchy"
            }
         },
         "tokenizer": {
            "ip4_hierarchy": {
               "type": "PathHierarchy",
               "delimiter": "."
            }
         }
      }
   },
   "mappings": {
      "log": {
         "properties": {
            "status": {
               "type": "integer"
            },
            "remote_host": {
               "type": "string",
                "index": "not_analyzed",
               "fields": {
                  "subs": {
                     "type": "string",
                     "index_analyzer": "ip4_analyzer",
                     "search_analyzer": "keyword"
                  }
               }
            }
         }
      }
   }
}'

unzip data.zip

curl -XPOST "$es_host/mylogs/_bulk" --data-binary @anon_data.bulk
curl -XPOST "$es_host/mylogs/_refresh" 



