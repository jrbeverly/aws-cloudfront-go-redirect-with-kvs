# Go redirects with CloudFront KeyValueStore

Can a CloudFront distribution serve go-link style redirects (`/<key>` -> 302 to
a stored URL) entirely at the edge, using a CloudFront Function that reads a
CloudFront KeyValueStore, with no origin request and no Lambda?

The experiment should:

1. create one KeyValueStore seeded with a handful of known keys;
2. attach a viewer-request CloudFront Function that looks up the first path
   segment and returns a 302 with `Location` set to the stored URL;
3. return a plain 404 from the function for unknown keys;
4. provide one script that adds or changes a key through the KeyValueStore API
   (not by redeploying the function or distribution).

Observations to record:

- `curl -sI https://<distribution>.cloudfront.net/<key>` status and `Location`
  for known and unknown keys;
- whether a request ever reaches the origin;
- how long a KeyValueStore update takes to be visible at the edge;
- any limits hit (key/value size, function runtime, lookup latency).

Constraints: CloudFormation or Terraform in `us-east-1`, the default
`*.cloudfront.net` domain, a placeholder origin that is never expected to be
hit, and hardcoded seed keys.

Out of scope unless results show a need: custom domains and certificates,
authentication, a UI or admin API for managing links, analytics or click
counting, wildcard or parameterised links, Lambda@Edge, and multi-account or
multi-environment deployment.
