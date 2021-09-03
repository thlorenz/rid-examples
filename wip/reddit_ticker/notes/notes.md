## Getting Post Score

Just postfixing the URL with `.json` does the trick, i.e.

```sh
curl https://www.reddit.com/r/redditdev/comments/jybwt2/get_the_id_of_a_post.json > res.json
cat res.json | jq '.[0].data.children[0].data.score'
```

We can also extract the id and use it to get a smaller response for same post to keep querying
the score. 

NOTE: we need to include a user agent, but seems like any will do.

```sh
curl -H 'User-Agent: reddit-score' https://api.reddit.com/api/info?id=t3_jybwt2 > curl-api.json
cat curl-api.json | jq '.data.children[0].data.score'
```
