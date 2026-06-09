#  E-commerce Funnel Analysis

##  Overview  
End-to-end funnel analysis on e-commerce data to identify conversion drop-offs and key behavioral drivers.

---

##  Objective  
To identify where users drop off in the purchase journey and determine whether the issue is driven by pricing, UX, or user behavior.

---

##  Key Metrics  
-  45% drop-off from Add-to-Cart → Checkout  
-  ~55% conversion rate across all segments  
-  ~53 minutes average time from cart to checkout  

---

##  Key Findings  

###  No Segment-Level Issue  
- Conversion is consistent across country, device, and traffic source  
- Indicates no geographic, device, or channel-specific friction  

###  Pricing Not a Factor  
- No meaningful price difference between converted vs dropped sessions  

###  Low Engagement Drives Drop-Off  
- Dropped sessions: **~4 events per session**  
- Converted sessions: **~8 events per session**  
- Clear evidence of **lower user intent in dropped sessions**  

###  Cart Used as Wishlist  
- Users frequently add items without strong intent to purchase  
- Cart acts as a comparison or saving mechanism  

---

##  Root Cause  
The drop-off is primarily driven by **low purchase intent and delayed decision-making**, not checkout friction, pricing, or UX issues.

---

##  Business Recommendations  
-  Introduce urgency triggers (low-stock alerts, countdown timers)  
-  Provide checkout incentives (discounts, free shipping thresholds)  
-  Implement cart abandonment recovery (email reminders, retargeting)  
-  Build trust signals (reviews, return policies, secure payments)  
-  Simplify checkout (fewer steps, “Buy Now” options)  

---

##  Tech Stack & Skills  
- SQL (CTEs, aggregations, joins)  
- Query Optimization  
- Data Cleaning & Transformation  
- Data Modeling (session-level analysis)  
- Funnel & Behavioral Analysis  

---

##  Project Structure  
/data  
/sql  
- basic_funnel.sql  
- checkout_analysis.sql  
- root_cause.sql  
/views  

---

##  Outcome  
Identified that a 45% funnel drop is driven by **low user intent (4 vs 8 engagement gap)** rather than pricing or UX issues, and proposed actionable strategies to improve conversion and reduce decision delays.
