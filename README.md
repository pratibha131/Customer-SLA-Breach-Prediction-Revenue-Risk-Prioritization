# 🚦 Customer Support SLA Prioritization — Revenue Risk–Based Decision System
## 📌 Executive Summary
Support teams face a daily constraint: they cannot resolve all open tickets at once.
Traditional prioritization methods (FIFO or SLA-only) treat all tickets as equal, ignoring the business impact of customer churn.

This project builds a decision-support system that prioritizes customer support tickets based on revenue at risk, not ticket volume.

#### Key Result:
Fixing just 2 out of 5 tickets (40%) protects ~87% of the total revenue at risk, compared to ~8–35% under FIFO or SLA-only approaches.

## 🎯 Business Problem

Each morning, a Support Operations Manager must decide:

Which open tickets should be resolved today to minimize potential revenue loss?

Constraints

Limited support capacity

SLA deadlines vary by priority

Customers have unequal business value

Not all SLA breaches carry the same financial risk

#### Why this matters

Resolving the wrong tickets first disproportionately impacts high-value customers, increasing churn and revenue loss. 

## 🧠 Solution Approach

This project combines SQL, Python, and Excel, each used where it is strongest:

| Layer          | Tool        | Purpose                           |
| -------------- | ----------- | --------------------------------- |
| Data layer     | SQL (MySQL) | SLA timing, joins, urgency logic  |
| Risk modeling  | Python      | Churn risk & revenue impact       |
| Decision layer | Excel       | Operational & executive decisions |

## 🗂️ Data Model (SQL)
#### Core Tables

customers — segment, tenure, lifetime value (LTV)

support_tickets — open tickets with timestamps and text

sla_policies — SLA windows by priority

Derived Fields (SQL)

Ticket age (minutes → hours)

SLA remaining time

SLA status: BREACHED / NEAR_BREACH / SAFE

#### Urgency rank using window functions

SQL handles deterministic logic (time, SLA rules).

#### 🐍 Risk Modeling (Python)

Python adds intelligence that SQL should not handle:

Churn Risk Framework (Explainable)

Churn risk is estimated using a rule-based scoring system combining:

SLA breach severity

Ticket sentiment (NLP)

Customer tenure

This is decision-support scoring, not a predictive ML model.

`churn_risk = f(SLA_status, sentiment, tenure)
revenue_at_risk = customer_LTV × churn_risk`

#### Final Priority Score

Urgency × Business impact:

`priority_score = revenue_at_risk / (|SLA_remaining_hours| + 1)`

## 📊 Decision Outputs (Excel)
### Sheet 1 — Daily Ticket Prioritization (Operations)

A ranked, action-ready list for daily stand-ups:

| Rank | Ticket | SLA Status  | Revenue at Risk | Action             |
| ---- | ------ | ----------- | --------------- | ------------------ |
| 1    | T105   | BREACHED    | ₹5.9L           | Fix immediately    |
| 2    | T104   | NEAR_BREACH | ₹50K            | Fix today          |
| 3    | T103   | BREACHED    | ₹44K            | Assign if capacity |


<img width="1392" height="264" alt="image" src="https://github.com/user-attachments/assets/6f11c9c0-52ed-41e3-a1d1-e292bcc9f122" />

### Sheet 2 — Revenue Impact Summary (Executives)

Fixing just 2 of 5 tickets (40%) protects ~87% of revenue at risk.

<img width="1091" height="329" alt="image" src="https://github.com/user-attachments/assets/cf5948cd-f1fc-4724-bf12-3d30c064faf6" />

Revenue protected refers to potential churn-related revenue loss avoided by resolving selected tickets.

#### Key metrics:

Total open tickets

Tickets fixed today

Total revenue at risk

Revenue protected today

% revenue protected



### Sheet 3 — Trade-off Comparison

| Strategy                        | Tickets Fixed | % Revenue Protected |
| ------------------------------- | ------------- | ------------------- |
| FIFO                            | 2             | ~8%                 |
| SLA-only                        | 2             | ~35%                |
| **Revenue-risk (this project)** | 2             | **87%**             |


<img width="1435" height="475" alt="image" src="https://github.com/user-attachments/assets/5360abef-e209-40fa-8d2d-5c52e556f156" />


Under identical capacity constraints, revenue-risk prioritization consistently outperforms FIFO and SLA-only approaches.

## ✅ Key Insights

Revenue risk is highly concentrated in a small number of tickets

SLA urgency alone is insufficient for business decisions

Explainable scoring beats black-box ML for operational prioritization

Small, targeted actions can prevent disproportionate revenue loss


## ⚠️ Assumptions & Limitations

Customer LTV and churn risk are estimated, not observed

Sentiment analysis uses lightweight NLP suitable for short ticket text

SLA penalties are modeled, not contract-specific

Designed for daily prioritization, not long-term churn prediction


## 🔮 Next Improvements

Calibrate churn risk weights using historical churn outcomes

Incorporate SLA penalty multipliers directly into priority scoring

Extend to staffing optimization (how many tickets can be fixed)

Automate daily refresh using scheduled pipelines


## 🏁 Final Takeaway

This project demonstrates how analytics should be used in practice:

Not to create dashboards — but to make decisions under constraints.

It translates raw operational data into clear, defensible actions that protect revenue.

