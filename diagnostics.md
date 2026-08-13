## 1
postgres    20 hours ago     Up 16 minutes (healthy)
postgrest   12 minutes ago   Up 12 minutes (healthy)
web         3 minutes ago    Up 3 minutes (healthy)
## 2
web- запущен на порту 3000 ошибок нет образ alphine
postgres - запущен на порту 5432 ошибок нет
postgrest - 3000 и админский для проверки 3001 образ alphine ошибок нет
## 3 
curl -i http://192.168.56.101:3000/health
HTTP/1.1 200 OK
cache-control: no-store, must-revalidate
content-type: text/html; charset=utf-8
link: </_next/static/css/index.5Ar120tL.css>; rel=preload; as="style", </_next/static/_vinext_fonts/geist-8ac0455e797f/geist-98bbbccb.woff2>; rel=preload; as=font; type=font/woff2; crossorigin, </_next/static/_vinext_fonts/geist-mono-00e989178794/geist-mono-013b2f2f.woff2>; rel=preload; as=font; type=font/woff2; crossorigin
vary: RSC, Next-Router-State-Tree, Next-Router-Prefetch, Next-Router-Segment-Prefetch, Next-Url, X-Vinext-Interception-Context, X-Vinext-Mounted-Slots, X-Vinext-Rsc-Render-Mode, Accept-Encoding
Date: Tue, 11 Aug 2026 10:14:43 GMT
Connection: keep-alive
Keep-Alive: timeout=5
Transfer-Encoding: chunked
curl -i http://192.168.56.101:3000/api/health
HTTP/1.1 200 OK
content-type: application/json
vary: RSC, Next-Router-State-Tree, Next-Router-Prefetch, Next-Router-Segment-Prefetch, Next-Url, X-Vinext-Interception-Context, X-Vinext-Mounted-Slots, X-Vinext-Rsc-Render-Mode, Accept-Encoding
Date: Tue, 11 Aug 2026 10:14:09 GMT
Connection: keep-alive
Keep-Alive: timeout=5
Transfer-Encoding: chunked

{"status":"ok","database":"connected"}
curl -i http://192.168.56.101:3000/api/tasks
HTTP/1.1 200 OK
content-type: application/json
vary: RSC, Next-Router-State-Tree, Next-Router-Prefetch, Next-Router-Segment-Prefetch, Next-Url, X-Vinext-Interception-Context, X-Vinext-Mounted-Slots, X-Vinext-Rsc-Render-Mode, Accept-Encoding
Date: Tue, 11 Aug 2026 10:13:17 GMT
Connection: keep-alive
Keep-Alive: timeout=5
Transfer-Encoding: chunked
## 4 
docker inspect site-web-1
                "Status": "healthy",
                "FailingStreak": 0,
                "Log": [
                    {
                        "Start": "2026-08-11T10:14:43.905564284Z",
                        "End": "2026-08-11T10:14:43.955995544Z",
                        "ExitCode": 0,
                        "Output": ""
                    },
                    {
                        "Start": "2026-08-11T10:14:53.956612704Z",
                        "End": "2026-08-11T10:14:54.009721395Z",
                        "ExitCode": 0,
                        "Output": ""
                    },
                    {
docker inspect site-postgrest-1
     "Health": {
                "Status": "healthy",
                "FailingStreak": 0,
                "Log": [
                    {
                        "Start": "2026-08-11T10:17:02.233496356Z",
                        "End": "2026-08-11T10:17:02.27854364Z",
                        "ExitCode": 0,
                        "Output": "OK: http://0.0.0.0:3001/ready\n"
                    },
                    {
                        "Start": "2026-08-11T10:17:12.27901361Z",
                        "End": "2026-08-11T10:17:12.324994109Z",
                        "ExitCode": 0,
                        "Output": "OK: http://0.0.0.0:3001/ready\n"
                    },
                    {docker inspect site-postgres-1
                        "Start": "2026-08-11T10:16:00.021296995Z",
                        "End": "2026-08-11T10:16:00.068509659Z",
                        "ExitCode": 0,
                        "Output": "/var/run/postgresql:5432 - accepting connections\n"
                    },
                    {
                        "Start": "2026-08-11T10:16:07.359469374Z",
                        "End": "2026-08-11T10:16:07.405484034Z",
                        "ExitCode": 0,
                        "Output": "/var/run/postgresql:5432 - accepting connections\n"
                    },
                    {
## 5
Работают все сервисы, не перезапускались ни разу по ошибкам и т.д. 
Все работает хорошо нареканий нет
Отправил бы restAPI запрост т.е. curl
