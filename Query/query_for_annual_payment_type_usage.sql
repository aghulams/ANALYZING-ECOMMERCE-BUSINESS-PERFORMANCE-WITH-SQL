/* 
Saya memutuskan untuk membuat view untuk menyimpan dan mengakses hasil dari query kompleks 
dengan cara yang lebih terstruktur dan mudah dipahami.
*/

-- View 'payment_freq_by_year', menghitung jumlah penggunaan payment_type berdasarkan tahun
CREATE VIEW payment_freq_by_year AS
    SELECT 
        op.payment_type,
        CAST(EXTRACT(year FROM o.order_purchase_timestamp) AS VARCHAR) AS year, 
        COUNT(op.payment_type) AS freq
    FROM order_payments op
    JOIN orders o ON op.order_id = o.order_id
    GROUP BY year, op.payment_type;

-- View 'payment_totals', membuat pivot tabel
CREATE VIEW payment_totals AS
    SELECT
        year,
        SUM(CASE WHEN payment_type = 'credit_card' THEN freq ELSE 0 END) AS credit_card,
        SUM(CASE WHEN payment_type = 'boleto' THEN freq ELSE 0 END) AS boleto,
        SUM(CASE WHEN payment_type = 'voucher' THEN freq ELSE 0 END) AS voucher,
        SUM(CASE WHEN payment_type = 'debit_card' THEN freq ELSE 0 END) AS debit_card,
        SUM(CASE WHEN payment_type = 'not_defined' THEN freq ELSE 0 END) AS not_defined
    FROM payment_freq_by_year
    GROUP BY year;

-- Menggabungkan hasil view dengan total penggunaan payment_type untuk semua tahun
SELECT * FROM payment_totals

UNION ALL

SELECT
    'Total',
    SUM(credit_card),
    SUM(boleto),
    SUM(voucher),
    SUM(debit_card),
    SUM(not_defined)
FROM payment_totals;

