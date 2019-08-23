# SecondQueue


#### Getting Started
* Ensure to run `mix deps.get` to gather dependencies



### Features
* Query Parameter validator to check for `queue` and `message` query params
* Queue store process to maintain state of queues and associated messages
* Separate processes for each queue to handle checking queue and printing at regular interval
* 404 endpoint for unsupported endpoint and unsupported verbs
* Tests to validate that queues are operating and outputting correctly
