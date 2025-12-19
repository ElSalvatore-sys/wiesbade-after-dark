# 🎯 WiesbadenAfterDark Knowledge Base Reference

## CRITICAL: Search Before Implementing!

Before implementing ANY feature for WiesbadenAfterDark, search the knowledge base:

### Archon RAG Queries
```bash
# Booking/Reservation flows
archon:rag_search_knowledge_base("booking reservation flow UX")

# Loyalty programs
archon:rag_search_knowledge_base("loyalty points rewards tier")

# German market specifics
archon:rag_search_knowledge_base("German gastronomy payment GDPR")

# Nightlife/Club features
archon:rag_search_knowledge_base("nightlife club table booking")

# Venue owner dashboard
archon:rag_search_knowledge_base("venue owner dashboard analytics")

# Event ticketing
archon:rag_search_knowledge_base("event ticketing antibot waitlist")
```

### Local Research Files
Location: `~/knowledge-base-research/companies/`

Categories:
- `01-booking-systems/` - OpenTable, Resy, SevenRooms, TheFork
- `02-nightlife/` - Resident Advisor, Discotech, Dice, Xceed, Fever
- `04-loyalty-programs/` - Punchh, Fivestars
- `06-german-specific/` - Quandoo, Gastrofix, Orderbird, Eventim, Lieferando
- `10-emerging/` - Partiful, Posh, Yelp, Foursquare

### Key Best Practices (Quick Reference)

| Feature | Best Practice | Source |
|---------|---------------|--------|
| No-show reduction | YUMS loyalty points | TheFork |
| Anti-scalping | Waitlist + anti-bot | Dice |
| German compliance | GoBD, DATEV, TSE | Gastrofix |
| Social virality | Invite-first model | Partiful |
| Loyalty cashback | 1000pts = €15 | Quandoo |
| Commission model | 10% + €0.99/ticket | Posh |

### When to Search

- Implementing booking flow → Search "booking flow"
- Adding loyalty system → Search "loyalty points"
- Building owner dashboard → Search "venue dashboard"
- Payment integration → Search "German payment"
- Event features → Search "ticketing event"

## Summary Document
Full analysis: `~/knowledge-base-research/WiesbadenAfterDark_Competitive_Research_Summary.docx`
