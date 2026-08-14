-- Xếp hạng khách hàng theo tổng chi tiêu, thử cả 3 hàm rank

With customer_spending AS (
    SELECT
        customer_id,
        SUM(total) as total_spent
    FROM invoice
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_spent,
    ROW_NUMBER() OVER (ORDER BY total_spent DESC) AS row_number_rank,
    RANK() OVER (ORDER BY total_spent DESC) AS rank_rank,
    DENSE_RANK() OVER (ORDER BY total_spent DESC) AS dense_rank_rank
FROM customer_spending
ORDER BY total_spent DESC;


