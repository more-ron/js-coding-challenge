# Jungle Scout: Coding Challenge 2018-09-07 

This is a dirty hack to retrieve and display publicly available information about Amazon products.

This process of retrieving data from Amazon is not recommended as web pages provides no contract 
to maintain document structure and could change at anytime. Use this only as a demo.  

Acceptance Criteria:
* ✓ must be able to retrieve product information given ASIN (Amazon Standard Identification Number)
* ✓ must be able to fetch product category
* ✓ must be able to fetch product rank
* ✓ must be able to fetch product dimensions
* ✓ must be able to store data in some sort of database
* ✓ must be able to display data on the frontend

Added Features:
* caching of product data
* 5-minute product data retention
* background product data update

Main Components:
* Frontend: [app/javascript/packs/components/app.vue](https://github.com/more-ron/js-coding-challenge/blob/master/app/javascript/packs/components/app.vue)
* API Endpoint: [app/controllers/api/v1/products_controller.rb](https://github.com/more-ron/js-coding-challenge/blob/master/app/controllers/api/v1/products_controller.rb)
* Product Model: [app/models/product.rb](https://github.com/more-ron/js-coding-challenge/blob/master/app/models/product.rb)
* Product Retrieval Job: [app/jobs/retrieve_product_job.rb](https://github.com/more-ron/js-coding-challenge/blob/master/app/jobs/retrieve_product_job.rb)
* DB Schema: [db/schema.rb](https://github.com/more-ron/js-coding-challenge/blob/master/db/schema.rb)

Limitations:
* Amazon "integration" is not done through official API endpoints to skip applying for associate
  credentials. Making this implementation unreliable and could fail randomly since Amazon product
  pages are not consistent in their structure.
* Amazon sometimes return a 503 "Service Not Available" status when it detects requests that are
  not from the browser. It normally returns back to normal responses after an hour or so.

TODO:
* Add error notification/tracking (recommendation: Rollbar, BugSnag, HoneyBadger, etc.)
* Add metric tracking (recommendation: Mixpanel)
* Add authentication (recommendation: Auth0)

-- MoreRon 
