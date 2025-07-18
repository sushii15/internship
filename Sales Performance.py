from flask import Flask, render_template_string
import pandas as pd
import mysql.connector
import matplotlib.pyplot as plt
import seaborn as sns
import io
import base64

app = Flask(__name__)

# Connect to MySQL
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Sasha123##",  # add password if needed
    database="assignment15",
    port=3306
)

# Load tables
df_customers = pd.read_sql("SELECT * FROM customers", conn)
df_products = pd.read_sql("SELECT * FROM products", conn)
df_orders = pd.read_sql("SELECT * FROM orders", conn)

# Prepare data
df_customers = df_customers.rename(columns={"name": "customer_name"})
df_products = df_products.rename(columns={"name": "product_name"})
df = df_orders.merge(df_customers, on="customer_id").merge(df_products, on="product_id")
df["revenue"] = df["quantity"] * df["price"]
df["order_date"] = pd.to_datetime(df["order_date"])
df["month"] = df["order_date"].dt.to_period("M")

# Chart helper
def plot_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format="png")
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')

@app.route("/")
def dashboard():
    total_revenue = df["revenue"].sum()
    top_products = df.groupby("product_name")["revenue"].sum().sort_values(ascending=False).head(5)
    regional_sales = df.groupby("region")["revenue"].sum().sort_values(ascending=False)
    monthly_revenue = df.groupby("month")["revenue"].sum()

    fig1, ax1 = plt.subplots(figsize=(6, 4))
    sns.barplot(x=top_products.values, y=top_products.index, ax=ax1)
    ax1.set_title("Top 5 Products by Revenue")
    top_products_img = plot_to_base64(fig1)

    fig2, ax2 = plt.subplots(figsize=(6, 4))
    sns.barplot(x=regional_sales.values, y=regional_sales.index, ax=ax2)
    ax2.set_title("Revenue by Region")
    regional_sales_img = plot_to_base64(fig2)

    fig3, ax3 = plt.subplots(figsize=(6, 4))
    monthly_revenue.plot(ax=ax3, marker='o')
    ax3.set_title("Monthly Revenue Trend")
    monthly_img = plot_to_base64(fig3)

    html = f'''
    <h1>📊 Sales Dashboard</h1>
    <h3>Total Revenue: ${total_revenue:,.2f}</h3>

    <h4>Top Products</h4>
    <img src="data:image/png;base64,{top_products_img}"/>

    <h4>Revenue by Region</h4>
    <img src="data:image/png;base64,{regional_sales_img}"/>

    <h4>Monthly Revenue Trend</h4>
    <img src="data:image/png;base64,{monthly_img}"/>
    '''

    return render_template_string(html)

if __name__ == "__main__":
    app.run(debug=True)