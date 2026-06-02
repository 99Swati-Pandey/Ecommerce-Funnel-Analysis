

--OPEN FUNNEL
WITH session_stage_flags AS (
    SELECT 
        s.session_id,
        s.customer_id,
        s.start_time,

        MAX(CASE WHEN e.event_type = 'page_view'   THEN 1 ELSE 0 END) AS page_view,
        MAX(CASE WHEN e.event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS add_to_cart,
        MAX(CASE WHEN e.event_type = 'checkout'    THEN 1 ELSE 0 END) AS checkout

    FROM sessions s
    LEFT JOIN events e
        ON s.session_id = e.session_id
    GROUP BY s.session_id, s.customer_id, s.start_time
),

session_purchase AS (
    SELECT 
        s.session_id,
        1 AS purchase
    FROM sessions s
    JOIN orders o 
        ON s.customer_id = o.customer_id
       AND o.order_time >= s.start_time
       AND o.order_time <= DATEADD(hour, 2, s.start_time)
    GROUP BY s.session_id
),

final_flags AS (
    SELECT 
        sf.session_id,
        sf.page_view,
        sf.add_to_cart,
        sf.checkout,
        ISNULL(sp.purchase, 0) AS purchase
    FROM session_stage_flags sf
    LEFT JOIN session_purchase sp
        ON sf.session_id = sp.session_id
),

stage_counts AS (
    SELECT
        COUNT(*) AS total_sessions,
        SUM(page_view)   AS page_view_sessions,
        SUM(add_to_cart) AS cart_sessions,
        SUM(checkout)    AS checkout_sessions,
        SUM(purchase)    AS purchase_sessions
    FROM final_flags
),

funnel_output AS (
    SELECT 1 AS stage_order, 'page_view' AS stage,
           page_view_sessions AS sessions,
           total_sessions AS prev_stage_sessions,
           total_sessions
    FROM stage_counts

    UNION ALL
    SELECT 2, 'add_to_cart', cart_sessions, page_view_sessions, total_sessions FROM stage_counts
    UNION ALL
    SELECT 3, 'checkout', checkout_sessions, cart_sessions, total_sessions FROM stage_counts
    UNION ALL
    SELECT 4, 'purchase', purchase_sessions, checkout_sessions, total_sessions FROM stage_counts
)

SELECT
    stage,
    sessions,
    ROUND(100.0 * sessions / total_sessions, 2) AS conversion_from_total_pct,
    ROUND(100.0 * sessions / NULLIF(prev_stage_sessions, 0), 2) AS conversion_from_previous_pct,
    ROUND(100.0 * (prev_stage_sessions - sessions) / NULLIF(prev_stage_sessions, 0), 2) AS drop_off_pct
FROM funnel_output
ORDER BY stage_order;
-- Result :- OPEN FUNNEL CHECKOUT SESSION = 44909 and purchase = 24196

--SEQUENTIAL FUNNEL

WITH first_stage_times AS (
    SELECT
        session_id,

        MIN(CASE WHEN event_type = 'page_view'   THEN [timestamp] END) AS page_view_time,
        MIN(CASE WHEN event_type = 'add_to_cart' THEN [timestamp] END) AS add_to_cart_time,
        MIN(CASE WHEN event_type = 'checkout'    THEN [timestamp] END) AS checkout_time

    FROM events
    GROUP BY session_id
),

session_purchase AS (
    SELECT 
        s.session_id,
        MIN(o.order_time) AS purchase_time
    FROM sessions s
    JOIN orders o 
        ON s.customer_id = o.customer_id
       AND o.order_time >= s.start_time
       AND o.order_time <= DATEADD(hour, 2, s.start_time)
    GROUP BY s.session_id
),

sequential_flags AS (
    SELECT
        f.session_id,

        CASE WHEN page_view_time IS NOT NULL THEN 1 ELSE 0 END AS page_view,

        CASE 
            WHEN add_to_cart_time IS NOT NULL
             AND page_view_time IS NOT NULL
             AND add_to_cart_time > page_view_time
            THEN 1 ELSE 0 
        END AS add_to_cart,

        CASE 
            WHEN checkout_time IS NOT NULL
             AND add_to_cart_time IS NOT NULL
             AND page_view_time IS NOT NULL
             AND add_to_cart_time > page_view_time
             AND checkout_time > add_to_cart_time
            THEN 1 ELSE 0 
        END AS checkout,

        CASE 
            WHEN sp.purchase_time IS NOT NULL
             AND checkout_time IS NOT NULL
             AND add_to_cart_time IS NOT NULL
             AND page_view_time IS NOT NULL
             AND add_to_cart_time > page_view_time
             AND checkout_time > add_to_cart_time
             AND sp.purchase_time > checkout_time
            THEN 1 ELSE 0 
        END AS purchase

    FROM first_stage_times f
    LEFT JOIN session_purchase sp
        ON f.session_id = sp.session_id
),

stage_counts AS (
    SELECT
        COUNT(*) AS total_sessions,
        SUM(page_view)   AS page_view_sessions,
        SUM(add_to_cart) AS cart_sessions,
        SUM(checkout)    AS checkout_sessions,
        SUM(purchase)    AS purchase_sessions
    FROM sequential_flags
),

funnel_output AS (
    SELECT 1 AS stage_order, 'page_view' AS stage,
           page_view_sessions AS sessions,
           total_sessions AS prev_stage_sessions,
           total_sessions
    FROM stage_counts

    UNION ALL
    SELECT 2, 'add_to_cart', cart_sessions, page_view_sessions, total_sessions FROM stage_counts
    UNION ALL
    SELECT 3, 'checkout', checkout_sessions, cart_sessions, total_sessions FROM stage_counts
    UNION ALL
    SELECT 4, 'purchase', purchase_sessions, checkout_sessions, total_sessions FROM stage_counts
)

SELECT
    stage,
    sessions,
    ROUND(100.0 * sessions / total_sessions, 2) AS conversion_from_total_pct,
    ROUND(100.0 * sessions / NULLIF(prev_stage_sessions, 0), 2) AS conversion_from_previous_pct,
    ROUND(100.0 * (prev_stage_sessions - sessions) / NULLIF(prev_stage_sessions, 0), 2) AS drop_off_pct
FROM funnel_output
ORDER BY stage_order;
--Result :- SEQUENTIAL FUNNEL CHECKOUT = 44786 and purchase = 24105


-- Final Observation :- There is 44909 -44786 = 123 sessions where a checkout event exists 
--  but did not occur after a valid add_to_cart event.

--Only 0.27%(123/44909) of checkout sessions violate sequential order which is statistically negligible
--and does not materially impact funnel interpretation.

--Since only 0.27% of sessions violate stage order, event tracking integrity is strong. 
--Therefore, the open funnel is statistically safe to use for further business analysis
--and decision-making.

-- -- Funnel tracking is highly reliable and sequential behavior is valid.

