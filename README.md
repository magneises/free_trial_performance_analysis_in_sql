# free_trial_performance_analysis_in_sql
How much is a free trial worth? In this SQL live training, you'll learn how to use SQL to analyze marketing data for a free trial of a product. You’ll summarize and aggregate data to calculate the sorts of metrics that are the bread and butter of any marketing analyst role.

## The Data

## Data Access

To access the data, create a **PostgreSQL integration** with the following details:

- host: `workspacedemodb.datacamp.com`
- port: `5432`
- database: `free_trial_performance`
- username: `competition_free_trial`
- password: `workspace`

## Data Deals

We'll be using synthetic data that was created for this training. This data represents a product that is sold via a 1-month free trial. The Free Trials table records instances of customers beginning a free trial. 1 month after the free trial period starts, the customer may choose to pay, and if so we will have a Purchase record.

There are four tables:

### Free Trials
A list of instances of free trials starts.

- Trial ID - An ID unique to the Free Trial.
- Free Trial Start Date - The date when the customer began their free trial.
- Region - The world region where the customer is located.

### Purchases
A list of instances of customers paying, following their free trial.

- Trial ID - The ID of the free trial, from the Free Trials table. This ID is unique as each trial may have a maximum of 1 purchase asociated with it.
- Purchase Date - The date when the customer made their purchase, 1 month after they began their free trial.
- Purchase Value - The USD value of the Customer's purchase.

### Dates
A list of dates, provided for convenience.

- Date - A sequential list of dates.
- Month - The first of the month for each date.

### Prices
_Optional_ - a list of prices of the product by region over time. This table will not be used in the live training, and is for optional follow-up activity. Prices are set on a Monthly basis, but the price for each customer is set at the beginning of their free trial, so subsequent price changes will not affect a customer.

- Free Trial Start Month - the month of free trials that the price applies to.
- Region - the customer's world region, as in the Free Trials table.
- The price that will be locked in at the beginning of the customer's Free Trial, based on their Free Trial Start Month & Region.

![Alt text] (https://drive.google.com/file/d/11XDvDbehp1QIr_AS5uYjkKANsRcS9NVX/view?usp=sharing "Free Trial Performance Analysis in SQL Data Schema")


