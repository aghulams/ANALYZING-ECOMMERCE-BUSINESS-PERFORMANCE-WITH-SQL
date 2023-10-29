WITH 
  -- CTE 1: Revenue (harga + biaya pengiriman) per tahun
  annual_revenue AS (
      SELECT 
          EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
          SUM(oi.freight_value + oi.price) AS revenue
      FROM
          orders o
      JOIN 
          order_items oi ON o.order_id = oi.order_id
      WHERE 
          o.order_status = 'delivered'
      GROUP BY 
          year
  ),
  
  -- CTE 2: Jumlah pesanan yang dibatalkan per tahun
  annual_canceled_order AS (
      SELECT
          EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
          COUNT(order_status) AS order_canceled
      FROM 
          orders o
      WHERE 
          order_status = 'canceled'
      GROUP BY 
          year
  ),
  
  -- CTE 3: 3 Kategori produk dengan revenue terbesar per tahun
  annual_top_products AS (
      SELECT
          EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
          p.product_category_name AS product_category,
          SUM(oi.freight_value + oi.price) AS revenue,
          RANK() OVER (PARTITION BY EXTRACT(YEAR FROM o.order_purchase_timestamp) ORDER BY SUM(oi.freight_value + oi.price) DESC) AS revenue_ranked
      FROM
          orders o
      JOIN
          order_items oi ON oi.order_id = o.order_id
      JOIN
          products p ON p.product_id = oi.product_id
      WHERE
          o.order_status = 'delivered'
      GROUP BY
          year, product_category
  ),
  
  -- CTE 4: 4 Kategori produkdengan jumlah pesanan yang dibatalkan terbanyak per tahun
  annual_canceled_products AS (
      SELECT 
          EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
          p.product_category_name AS product_category,
          COUNT(order_status) AS canceled_order,
          RANK() OVER (PARTITION BY EXTRACT(YEAR FROM order_purchase_timestamp) ORDER BY COUNT(order_status) DESC) AS canceled_ranked
      FROM
          orders o
      JOIN
          order_items oi ON oi.order_id = o.order_id
      JOIN
          products p ON p.product_id = oi.product_id
      WHERE
          o.order_status = 'canceled'
      GROUP BY
          year, p.product_category_name
  )
  
  -- Tabel Utama: Annual Product Category Quality Master Table
  SELECT 
      ar.year,
			ar.revenue AS total_revenue,
      aco.order_canceled AS total_canceled,
      atp.product_category AS top_revenue_product,
      atp.revenue AS top_revenue,
      acp.product_category AS most_canceled_product,
      acp.canceled_order AS top_canceled 
  FROM 
      annual_revenue ar
  JOIN
      annual_canceled_order aco ON ar.year = aco.year
  JOIN
      annual_top_products atp ON ar.year = atp.year
  JOIN
      annual_canceled_products acp ON ar.year = acp.year
  WHERE 
      atp.revenue_ranked = 1 AND acp.canceled_ranked = 1;
