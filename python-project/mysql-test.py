from utils import *

customer_data = [ #id, full_name, country
                 ['1','Matt Connory','USA'],
                 ['2','Hunyadi Janos','Hungary'],
                 ['3','Miron Cozma','Romania'],
                 ['4','Banel Nicolita','Romania'],
                 ['5','Gigi Becali','Romania'],
                ]

product_data = [# name, category
               ['Pringles Salt', 'Food'],
               ['Cement', 'Construction Materials'],
               ['TV', 'Electronics'],
               ['Laptop', 'Electronics'],
               ['Phone', 'Electronics'],
               ['Pizza base', 'Food'],
               ]


sales_data = [#price,quantity,sale_date,customer_id,product_id
             ['1000', '1', '2021-01-02', '2', '3'],
             ['10.3', '10.5', '2022-09-02', '2', '2'],
             ['10', '3', '2022-09-02', '2', '1'],
             ['10', '10', '2022-10-12', '1', '1'],
             ['9.9', '10', '2022-09-12', '1', '1'],
             ['9.8', '9', '2022-08-12', '1', '1'],
             ['9.7', '1', '2022-08-12', '1', '1'],
             ['2000', '2', '2021-08-13', '3', '4'],
             ['900', '1', '2022-08-13', '3', '5'],
             ['9.7', '5', '2022-08-13', '2', '6'],
             ['2000', '1', '2022-12-13', '2', '4'],
             ['1000', '1', '2022-11-13', '4', '5'],
             ['500', '1', '2022-10-13', '5', '5'],
             ]



# possible cases for the task: existing data outside [2021 - 2023) interval
# that might modify the outcomes of the data within the interval
# For example: outside [2021-2023) Hunyadi Janos and Matt Connory should account for top 10% of sales
# inside [2021-2023) Miron Cozma should account for top 10% of sales

try:
    # connect with my credentials - I don't use this password anywhere else
    connection = mysql.connector.connect(host='localhost',password='@Og2345678',user='root')
    if connection.is_connected():
        db_Info = connection.get_server_info()
        print("Connected to MySQL Server version ", db_Info)
        # Initialize the connection, clear and then create the database.
        cursor = connection.cursor(buffered=True)

        # Use cursor.execute() to run any SQL query with a string. Any SQL error will result in a Python error as well.
        # Catching first error to avoid crashes if the database was not yet created.
        try:
            cursor.execute("drop database sales_db;")
        except Exception as e:
            print("This is the first run and db was not created.")
            print("Exception is:", e)
            pass

        cursor.execute("create database sales_db;")
        cursor.execute("use sales_db;")

        # Execute the creation of tables
        for q in table_queries:
            cursor.execute(q)

        # Populate tables with data.
        # Because p is a list, I can pass its contents as arguments by preceding it with the * operator.
        # The functions called within cursor.execute() return strings as needed.
        for p in product_data:
            cursor.execute(insert_into_products(*p))

        for c in customer_data:
            cursor.execute(insert_into_customers(*c))

        for s in sales_data:
            cursor.execute(insert_into_sales(*s))
        # Commit data insertion to database to have data for the questions_queries.
        connection.commit()
        answers = []
        for q in questions_queries:
            a = cursor.execute(q[1])
            ans = np.array(cursor.fetchall())
            answers.append([q[0], ans])
            print(q[0],ans, ans.shape)

        data = answers[0][1]
        x_values = data[:, 0]
        y_values = data[:, 1]

        # Create a bar chart
        plt.bar(x_values, y_values)

        # Set labels and title
        plt.xlabel('Product Category')
        plt.ylabel('Total Revenue')
        plt.title("Total revenue per Category")

        # Display the chart
        plt.show()

        data = answers[1][1]

        # Extract data for plotting
        x_values = data[:, 2].astype(int)  # Convert column 2 to int for horizontal axis - month index
        y_values = data[:, 3].astype(float)  # Convert column 3 to float for vertical axis - quantity
        legend_labels = data[:, 5]  # Column 5 for legend labels

        # Create a dictionary to map product names in column 5 to legend labels above bars
        legend_mapping = {unique_value: f'Legend {unique_value}' for unique_value in np.unique(legend_labels)}

        # Create a bar chart
        plt.bar(x_values, y_values, tick_label=x_values, align='center')

        # Set labels and title
        plt.xlabel('Month')
        plt.ylabel('Quantity')
        plt.title('Best selling product monthly quantity')

        # Add legend with customized labels
        plt.legend([legend_mapping[label] for label in legend_labels])

        # Add text labels above each bar
        for x, y, label in zip(x_values, y_values, legend_labels):
            plt.annotate(label, (x, y), textcoords="offset points", xytext=(0, 10), ha='center')

        # Display the chart
        plt.tight_layout()
        plt.show()

except Error as e:
    print("Error while connecting to MySQL", e)
finally:
    if connection.is_connected():
        connection.commit() # to save the changes made by queries
        cursor.close()
        connection.close()
        print("MySQL connection is closed")