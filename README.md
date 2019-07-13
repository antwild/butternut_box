# Butternut Box - Scam detection task

If someone tries to sign up multiple times to use using a discount again and again, 
we want to be able to subtly detect and block them.

We’d like to detect them by checking to see if they match any two of the following three attributes of a pre-existing customer:
- Last Name
- Postcode
- Credit Card (By matching *both* the card's last four digits and the expiry date)

### Dependancies
You must have Ruby and sqlite3 installed.
Please clone the repository with the following command:

`git clone https://github.com/antwild/butternut_box.git`

### Assumptions
Some assumptions have been made with regard to the task that were not detailed in the brief:
- The `credit_cards` table contains the user_id foreign key because the User class `has_one :credit_card`
- The `expiry_month` and `expiry_year` columns in the `credit_cards` table are strings because `expiry_month`
can begin with a 0

### Database
The Database is sqlite3 and queries are written without an ORM.

The database contains three tables with the following data:

```
users
id          last_name 
----------  ----------
1           SMITH     
2           SMITH     
3           smith     
4           JONES     
5           carter    

addresses
id          postcode    user_id   
----------  ----------  ----------
1           SW183FR     1         
2           SW12 4SL    2         
3           BR220WK     3         
5           SS10 8AA    4         
6           WG72LL      5      

credit_cards
id          last_four_digits  expiry_month  expiry_year  user_id   
----------  ----------------  ------------  -----------  ----------
1           7835              2             20           1         
2           2901              6             2024         2         
3           8974              01            22           3         
4           4839              09            2021         4         
5           8324              11            2026         5 
```

### Functionality
When the class method `fradulent?` is run on an instance of `FraudDetector` (a user), the instance's attributes will be
checked against the database to see if the user is already a customer and whether or not they are entitled to a new customer
discount.

If `true` is returned, at least two of their last name, postcode or card details (number and expiry together) have been found
in the database against the same user and therefore, they are not entitled to a discount.

If `false` is returned, they do not appear in the database and are entitled to a discount.

### Review
Whilst this system can be effective, false positives can also occur for a number of reasons. For example:
- If customers with the same last name live on the same street
- If a current customer wants to purchase for a family member's dog (they do not live with) as a present using their 
already stored card 

The system can be made more robust with greater data captured from the user. Such as their first name (in `users`),
house number (in `addresses`), account number and sort code (in `credit_cards`). 
