-- Since drop is consistent across country/device/source, 
-- we now test behavioral & pricing factors.



-- Is product price influencing checkout drop?

SELECT 
    AVG(CASE WHEN sfb.checkout = 0 THEN sc.avg_price END) AS avg_price_dropped,
    AVG(CASE WHEN sfb.checkout = 1 THEN sc.avg_price END) AS avg_price_converted
FROM session_funnel_base sfb
JOIN (
    SELECT 
        e.session_id,
        AVG(p.price_usd) AS avg_price
    FROM events e
    JOIN products p
        ON e.product_id = p.product_id
    WHERE e.event_type = 'add_to_cart'
    GROUP BY e.session_id
) sc
    ON sfb.session_id = sc.session_id;

-- Result :- Price is NOT causing the 45% drop.

--          If price were the issue, dropped sessions would show significantly 
--          higher prices.But here:

--        * Prices are almost identical.
--        * Converted sessions even slightly higher.





-- Session Duration Comparison.
    SELECT 
    AVG(CASE WHEN checkout = 0 
             THEN DATEDIFF(second, first_event_time, last_event_time) END) AS avg_duration_dropped,
             
    AVG(CASE WHEN checkout = 1 
             THEN DATEDIFF(second, first_event_time, last_event_time) END) AS avg_duration_converted
FROM session_behavior_base;

-- Result:- The 45% cart-to-checkout drop does not appear to be driven by pricing, 
--          geography, device, or systemic UX friction. Dropped sessions exhibit
--          significantly shorter engagement time compared to converted sessions, 
--          suggesting lower purchase intent rather than checkout process failure.



-- Right now you have 2 strong signals:
--Dropped sessions have half the events
--Dropped sessions have shorter duration
--  That’s good.But to make it solid, we need multiple independent intent indicators.So we need to check -




-- Compare Page Views Before Add-to-Cart
SELECT 
    AVG(CASE WHEN checkout = 0 THEN page_views END) AS avg_pageviews_dropped,
    AVG(CASE WHEN checkout = 1 THEN page_views END) AS avg_pageviews_converted
FROM session_behavior_base;

-- Result:- Dropped sessions average 4 pageviews, while converted sessions average 5, indicating only a slight difference 
--          in browsing behavior.Therefore, pageview count alone does not provide strong evidence 
--          of lower purchase intent among users who dropped off.
WITH first_order AS (
    SELECT 
        customer_id,
        MIN(order_time) AS first_order_time
    FROM orders
    GROUP BY customer_id
),

session_data AS (
    SELECT 
        s.session_id,
        s.customer_id,
        s.start_time,
        MAX(CASE WHEN e.event_type = 'checkout' THEN 1 ELSE 0 END) AS reached_checkout
    FROM sessions s
    JOIN events e 
        ON s.session_id = e.session_id
    GROUP BY 
        s.session_id, 
        s.customer_id,
        s.start_time
)

SELECT 
    sd.reached_checkout,

    CASE 
        WHEN fo.first_order_time IS NULL THEN 'New'
        WHEN sd.start_time < fo.first_order_time THEN 'New'
        ELSE 'Returning'
    END AS customer_type,

    COUNT(*) AS sessions

FROM session_data sd
LEFT JOIN first_order fo
    ON sd.customer_id = fo.customer_id

GROUP BY 
    sd.reached_checkout,
    CASE 
        WHEN fo.first_order_time IS NULL THEN 'New'
        WHEN sd.start_time < fo.first_order_time THEN 'New'
        ELSE 'Returning'
    END;




--For Returning Users:

--Total Returning =38,611 (not reached) + 23,148 (reached)= 61,759
--Checkout reach rate (Returning): 23148 / 61,759 =  37.5%

--For New Users:

--Total New = 33,480 (not reached) + 21,761 (reached) = 58,241
--Checkout reach rate (New): 21,761 / 58,241 = 37.4%

--Result

--There is no meaningful difference between new and returning users.


-- Check number of page views per session.
SELECT 
    AVG(CASE WHEN checkout = 0 THEN total_events END) AS avg_events_dropped,
    AVG(CASE WHEN checkout = 1 THEN total_events END) AS avg_events_converted
FROM session_behavior_base;

--Result :- Converted sessions have an average of 8 total events, while dropped sessions 
--          average only 4 events. This shows that users who complete the checkout 
--          process interact much more with the platform, indicating stronger engagement 
--          and higher purchase intent compared to those who drop off earlier.


--The 45% drop between add-to-cart and checkout is not driven by pricing, geography, device, 
--traffic source, or user type.

--Instead, behavioral signals show that dropped sessions have significantly lower engagement 
--(fewer events and shorter duration), indicating weaker purchase intent.

--Therefore, the drop is primarily driven by low-intent users adding items to cart without a strong
--intention to complete the purchase, rather than friction in the checkout process.



--Time to checkout (intent strength)

WITH cart_time AS (
    SELECT session_id, MIN(timestamp) AS cart_time
    FROM events
    WHERE event_type = 'add_to_cart'
    GROUP BY session_id
),
checkout_time AS (
    SELECT session_id, MIN(timestamp) AS checkout_time
    FROM events
    WHERE event_type = 'checkout'
    GROUP BY session_id
)

SELECT 
    AVG(DATEDIFF(MINUTE, cart_time, checkout_time)) AS avg_time_to_checkout
FROM cart_time c
JOIN checkout_time ch 
    ON c.session_id = ch.session_id;

--Result:- Users take ~53 minutes on average to move from cart to checkout.
--         This indicates delayed decision-making rather than immediate purchase intent.
--         It suggests lack of urgency, with users treating the cart as a temporary holding space.



--Cart size (commitment level)
    WITH cart_items AS (
    SELECT 
        session_id,
        SUM(qty) AS total_items
    FROM events
    WHERE event_type = 'add_to_cart'
    GROUP BY session_id
)

SELECT 
    CASE 
        WHEN total_items = 1 THEN 'single'
        ELSE 'multi'
    END AS cart_type,
    COUNT(*) AS sessions
FROM cart_items
GROUP BY 
    CASE 
        WHEN total_items = 1 THEN 'single'
        ELSE 'multi'
    END;

--Result:- More users have multi-item carts (46,299) compared to single-item carts (35,219).
--         Despite higher engagement, a ~45% drop still occurs before checkout.
--         This shows users are exploring products but not committing to purchase.



--Conclusion:- The biggest drop (~45%) occurs between add-to-cart and checkout.
--             Conversion remains consistent across country, device, and source, ruling out 
--             external factors.Pricing also shows no significant impact on user drop-off.
--             Behavioral analysis indicates lower engagement and delayed decision-making (~53 mins).
--             Overall, users treat the cart as a wishlist/consideration tool, reflecting low urgency
--             and weak purchase intent.





--Recommended Solutions:-
--Add urgency triggers like low-stock alerts, countdown timers, and limited-time offers.
--Provide checkout incentives such as discounts, free shipping, and bundle offers.
--Implement cart abandonment recovery (email reminders, push notifications, retargeting ads).
--Build trust using ratings, reviews, return policies, and secure payment badges.
--Simplify checkout with fewer steps, autofill details, and “Buy Now” options.