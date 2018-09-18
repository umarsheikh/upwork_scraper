# upwork_scraper
scraper for upwork
*Test case*
1. Run `<browser>`
2. Clear `<browser>` cookies
3. Go to www.upwork.com
4. Focus onto "Find freelancers"
5. Enter `<keyword>` into the search input right from the dropdown and submit it (click on the magnifying glass button)
6. Parse the 1st page with search results: store info given on the 1st page of search results as structured data of any chosen by you type (i.e. hash of hashes or array of hashes, whatever structure handy to be parsed).
7. Make sure at least one attribute (title, overview, skills, etc) of each item (found freelancer) from parsed search results contains `<keyword>` Log in stdout which freelancers and attributes contain `<keyword>` and which do not.
8. Click on random freelancer's title
9. Get into that freelancer's profile
10. Check that each attribute value is equal to one of those stored in the structure created in #67
11. Check whether at least one attribute contains `<keyword>`
