WITH 
  -- CTE 1: Yearly_MAU, menghitung rata-rata Monthly Active User (MAU) per tahun
  annual_MAU AS (
    SELECT
      EXTRACT(year FROM order_purchase_timestamp) AS year,
      (COUNT(DISTINCT customer_unique_id)) / COUNT(DISTINCT EXTRACT(month FROM order_purchase_timestamp)) AS avg_mau
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY EXTRACT(year FROM order_purchase_timestamp)
  ),
  
  -- CTE 2: Yearly_New_Customers, total customer baru per tahun
  annual_new_customers AS (
    SELECT 
      year,
      COUNT(DISTINCT customer_unique_id) as new_customer
    FROM (
      SELECT
        EXTRACT(year FROM o.order_purchase_timestamp) as year,
        c.customer_unique_id
      FROM orders o
      JOIN customers c ON o.customer_id = c.customer_id
      GROUP BY 1, 2
    )
    GROUP BY year
  ),

  -- CTE 3: Customer_Repeat_Order, jumlah customer yang melakukan repeat order per tahun
  annual_customer_repeat_order AS (
    SELECT
      year, 
      COUNT(DISTINCT customer_unique_id) as repeat_customer
    FROM (
      SELECT
        EXTRACT(year FROM o.order_purchase_timestamp) as year,
        c.customer_unique_id
      FROM orders o 
      JOIN customers c ON o.customer_id = c.customer_id
      GROUP BY 1, 2
      HAVING COUNT(1) > 1
    )
    GROUP BY year
  ),

  -- CTE 4: Yearly_Avg_Order, rata-rata frekuensi order untuk setiap tahun
  annual_avg_order AS (
    SELECT 
      year, 
      ROUND(AVG(freq_order), 2) as avg_order 
    FROM (
      SELECT 
        EXTRACT(year FROM o.order_purchase_timestamp) as year, 
        c.customer_unique_id, 
        COUNT(1) as freq_order 
      FROM 
        orders o
      JOIN customers c ON o.customer_id = c.customer_id 
      GROUP BY 1, 2
    )
    GROUP BY year
  )
	
-- Tabel Utama: Annual Customer Growth Master Table
SELECT 
  am.year,
  am.avg_mau,
  anc.new_customer,
  acro.repeat_customer,
  aao.avg_order
FROM 
  annual_MAU am
JOIN 
  annual_new_customers anc ON am.year = anc.year
JOIN 
  annual_customer_repeat_order acro ON am.year = acro.year
JOIN 
  annual_avg_order aao ON am.year = aao.year;
