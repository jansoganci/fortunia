# 📋 GENERAL DEVELOPMENT RULES
**FORTUNIA iOS App**

**Version:** 1.0  
**Date:** October 24, 2025  
**Document Type:** Development Standards & Guidelines  
**Status:** Active Rules

---

## 🎯 **1. PROJECT PHILOSOPHY & PRINCIPLES**

### **Steve Jobs "Simplicity" Principle**
- **"Simplicity is the ultimate sophistication"** - Every feature must meet this standard
- **One Primary Action Per Screen** - Users should know what to do on every screen
- **Remove, Don't Add** - Perfect existing features instead of adding new ones
- **Focus Through Elimination** - Knowing what NOT to do is more important than what to do

### **"Think Fast, Iterate Faster" Approach**
- **Weekly Ship Cycle** - Visible improvement to users every week
- **Fail Fast, Learn Faster** - Remove failed features within 48 hours
- **Small Wins Create Momentum** - User satisfaction increase every sprint
- **Rapid Feedback Loops** - Quickly integrate user feedback

### **"Quality Over Quantity" Standard**
- **"Insanely Great" Test** - Features that meet Steve Jobs standards
- **Details Matter** - Even 2-second loading animations must be perfect
- **User-First Thinking** - Every decision should improve user experience
- **Cultural Respect** - Every cultural element must be handled with respect

---

## 🏗️ **2. ARCHITECTURE & CODE STANDARDS**

### **Modular Architecture**
- **Feature-Based Structure** - Each fortune type as separate module
- **Protocol-Driven Development** - Standardization with FortuneProcessor protocol
- **MVVM Pattern** - Clean separation of concerns
- **Dependency Injection** - Testable and flexible code structure

### **Tech Stack (Detailed)**
- **Frontend**: SwiftUI + Combine (iOS 15.0+)
- **Backend**: Supabase (auth, database, storage, edge functions)
- **AI/ML**: Gemini API (text generation), fal.ai (image analysis), Vision Framework (on-device)
- **Payments**: Adapty + StoreKit 2
- **Analytics**: Firebase Analytics + Crashlytics
- **Push Notifications**: Firebase Cloud Messaging + APNs
- **Multi-Language**: NSLocalizedString (EN + ES)

### **SwiftUI Best Practices**
- **Modern iOS Development** - Target iOS 15.0+
- **Declarative UI** - State-driven interface development
- **Performance Optimization** - Lazy loading and efficient rendering
- **Accessibility First** - VoiceOver and other accessibility features

### **Code Standards**
- **Naming Conventions** - Descriptive and consistent naming
- **Function Length** - Maximum 20 lines, single responsibility
- **Comment Strategy** - Comments explaining why something was done
- **Error Handling** - Graceful error recovery, user-friendly messages

---

## 🚀 **3. DEVELOPMENT PROCESS RULES**

### **Weekly Sprint Cycle**
- **Monday**: Sprint planning + previous week deployment
- **Tuesday-Thursday**: Build + test + iterate
- **Friday**: Code review + retrospective + next week planning
- **Weekend**: Creative exploration + learning

### **Feature Development Process**
- **Feature Flags** - A/B testing mechanism for new features
- **Fail Fast Framework** - Remove failed features within 48 hours
- **User Testing** - 5+ user tests for each feature
- **Quality Gates** - Mandatory quality controls for each feature

### **Learning & Development**
- **Learning Budget** - Learn 1 new thing per sprint, try 10 new things
- **Ask for Help** - Ask when stuck for more than 30 minutes
- **Documentation** - Document what you learn
- **Knowledge Sharing** - Weekly technical sharing sessions

---

## 🎨 **4. DESIGN & UX RULES**

### **Radical Simplicity**
- **One Primary Action Per Screen** - Users should know what to do on every screen
- **Maximum 3 Navigation Items** - Avoid complex menus
- **Remove, Don't Add** - Perfect existing features instead of adding new ones
- **Progressive Disclosure** - Show information progressively

### **Mystical Aesthetics**
- **Modern Mysticism** - Mystical but modern design language
- **Cultural Authenticity** - Correct symbols and colors for each culture
- **Delight in Details** - Loading animations, haptic feedback, sound design
- **Consistent Visual Language** - Consistent design throughout the app

### **User Experience Principles**
- **3-Second Rule** - All operations under 3 seconds
- **Loading States** - Visual feedback for every operation
- **Error Recovery** - Clear guidance in error situations
- **Accessibility** - Compliance with iOS accessibility standards

---

## 🔒 **5. SECURITY & PRIVACY RULES**

### **Privacy First Approach**
- **On-Device Processing** - Photos processed on device whenever possible
- **Data Minimization** - Only necessary data is collected
- **User Consent** - Clear and understandable consent mechanisms
- **Transparent Policies** - Transparency about data usage

### **Security Standards**
- **RLS Policies** - Supabase Row Level Security
- **Encryption** - All data encryption (at rest and in transit)
- **API Security** - Rate limiting and input validation
- **Regular Audits** - Regular security checks

### **Compliance**
- **GDPR Compliance** - European data protection regulation
- **App Store Guidelines** - Full compliance with Apple rules
- **Age Verification** - 18+ age limit (for premium subscription)
- **Entertainment Disclaimer** - "For entertainment purposes" warnings

---

## 📊 **6. PERFORMANCE & OPTIMIZATION**

### **Performance Standards**
- **3-Second Rule** - All operations under 3 seconds
- **Memory Management** - Efficient resource usage
- **Battery Optimization** - Background process minimization (AI processes only in foreground)
- **Network Efficiency** - Minimal API calls, smart caching

### **Image & Media Optimization**
- **Compressed Images** - Optimized file sizes
- **Lazy Loading** - Load when needed
- **Caching Strategy** - Smart cache management
- **Progressive Loading** - Progressive image loading

### **API & Data Management**
- **Rate Limiting** - Daily usage limits
- **Offline Support** - Core features work offline
- **Data Sync** - Background synchronization
- **Error Recovery** - Graceful handling of network errors

---

## 🧪 **7. TESTING & QUALITY CONTROL**

### **Critical Path Testing**
- **Payment Flow** - 100% working payment process
- **Fortune Creation** - Testing fortune creation flow
- **Share Functionality** - Testing sharing features
- **Subscription Management** - Testing subscription management

### **Testing Strategy**
- **Manual Testing** - 15 minutes manual testing before each release
- **TestFlight Beta** - 10-20 person test group
- **Crash Monitoring** - Firebase Crashlytics (automatic)
- **Performance Testing** - Load time and memory usage control

### **Quality Gates**
- **User Testing** - 5+ user tests for each feature
- **Performance Benchmarks** - Loading under 3 seconds
- **Accessibility Check** - VoiceOver and other features
- **Cultural Review** - Cultural sensitivity check

---

## 📱 **8. PLATFORM & DEVICE COMPATIBILITY**

### **iOS Support**
- **iOS 15.0+** - Minimum supported version
- **iPhone Focus** - iPhone priority development
- **iPad Support** - Responsive design
- **Dark Mode** - Full support and optimization

### **Device Compatibility**
- **iPhone 12+** - Primary target devices
- **iPhone SE** - Budget-friendly support
- **iPad** - Tablet-optimized experience
- **Accessibility** - VoiceOver, Dynamic Type, Switch Control

### **Performance Targets**
- **Launch Time** - Under 3 seconds
- **Memory Usage** - Under 100MB
- **Battery Impact** - Minimal background usage
- **Network Efficiency** - Minimal data usage

---

## 🌍 **9. MULTI-LANGUAGE & CULTURAL SUPPORT**

✅ **Localization: Fully implemented (English + Spanish)** — supports runtime switching via LocalizationManager.

### **Internationalization**
- **i18n Framework** - NSLocalizedString usage ✅ Completed (EN + ES)
- **10+ Languages** - First year target
- **RTL Support** - Arabic and Hebrew
- **Cultural Localization** - Customization for each region

### **Translation Workflow**
- **AI-Generated** - Initial translation with ChatGPT/Claude
- **Native Speaker Review** - Local speaker review
- **Cultural Validation** - Cultural accuracy check
- **Approve & Deploy** - Publish after approval

### **Cultural Sensitivity**
- **Cultural Advisors** - Freelance advisors for each culture
- **Authentic Symbols** - Correct cultural symbols
- **Respectful Representation** - Respectful representation
- **Community Feedback** - Local community feedback

---

## 💰 **10. MONETIZATION & SUBSCRIPTION**

### **Freemium Model**
- **Free Tier** - 3 readings per day (free forever)
- **Premium Tier** - $9.99/ay, unlimited readings

### **Pricing Strategy**
- **Clear Value Proposition** - Clear value for each tier
- **Fair Pricing** - Competitive and fair pricing
- **Trial Periods** - 7-day free trial (for Premium)
- **Refund Policy** - 7-day refund right

### **Payment Security**
- **Adapty Integration** - Subscription management
- **PCI Compliance** - Payment security
- **Fraud Prevention** - Fraud prevention
- **Secure Storage** - Secure data storage

---

## 📈 **11. ANALYTICS & METRICS**

### **Key Metrics Tracking**
- **Mixpanel/Amplitude** - Event tracking
- **Core Events** - reading_created, share_clicked, subscription_started
- **Retention Metrics** - Day 1, 7, 30 retention
- **Conversion Funnel** - Free to paid conversion

### **Analytics Strategy**
- **Daily Dashboard** - 5-minute morning metrics check
- **Weekly Deep Dive** - 30-minute detailed analysis
- **Monthly Review** - Strategic assessment
- **Real-time Alerts** - Critical metric changes

### **Privacy-Compliant Analytics**
- **GDPR Compliance** - European data protection
- **User Consent** - Analytics consent
- **Data Anonymization** - Personal data protection
- **Opt-out Options** - User preference

---

## 🚨 **12. ERROR MANAGEMENT & SECURITY**

### **Error Handling**
- **Graceful Recovery** - User-friendly messages in error situations
- **Fallback Strategies** - Alternative solutions
- **User Guidance** - Clear guidance and solution suggestions
- **Error Logging** - Detailed error records

### **Security Measures**
- **Crash Reporting** - Firebase Crashlytics
- **Security Audits** - Regular security checks
- **Data Breach Protocol** - Rapid response plan
- **Backup Strategy** - Data backup policy

### **Monitoring & Alerts**
- **Real-time Monitoring** - Live system monitoring
- **Performance Alerts** - Performance decline alerts
- **Error Rate Tracking** - Error rate tracking
- **User Impact Assessment** - User impact assessment

---

## 📚 **13. DOCUMENTATION & KNOWLEDGE MANAGEMENT**

### **Code Documentation**
- **Function Comments** - Description for each function
- **API Documentation** - Swagger/OpenAPI
- **Architecture Docs** - System architecture documentation
- **Decision Records** - Records of important decisions

### **User Documentation**
- **In-app Help** - In-app help system
- **User Guides** - User guides
- **FAQ Section** - Frequently asked questions
- **Video Tutorials** - Visual tutorials

### **Knowledge Management**
- **Changelog** - Detailed changes for each version
- **Learning Log** - Lessons learned
- **Best Practices** - Best practices
- **Troubleshooting** - Troubleshooting guides

---

## 🔄 **14. CONTINUOUS IMPROVEMENT**

### **Weekly Process**
- **Sprint Retrospectives** - Weekly feedback
- **User Feedback Analysis** - User feedback analysis
- **Performance Review** - Performance evaluation
- **Next Week Planning** - Next week planning

### **Monthly Reviews**
- **Strategic Assessment** - Strategic assessment
- **User Research** - User research
- **Competitor Analysis** - Competitor analysis
- **Roadmap Updates** - Roadmap updates

### **Quarterly Planning**
- **Long-term Vision** - Long-term vision
- **Feature Roadmap** - Feature roadmap
- **Resource Planning** - Resource planning
- **Market Analysis** - Market analysis

---

## 🚀 **15. DEPLOYMENT & RELEASE**

### **Deployment Strategy**
- **Manual Deployment** - Xcode Archive → TestFlight → App Store
- **Versioning** - Semantic versioning (1.0.0 → 1.1.0 → 2.0.0)
- **Staging Environment** - Test environment requirement
- **Production Deployment** - Live environment release

### **Release Process**
- **Feature Flags** - Gradual feature release
- **Rollback Strategy** - Quick rollback plan
- **Release Notes** - User-friendly descriptions
- **Hotfix Protocol** - Patch critical bugs within 24 hours

### **Quality Assurance**
- **Pre-release Testing** - Pre-release testing
- **User Acceptance Testing** - User acceptance testing
- **Performance Validation** - Performance validation
- **Security Check** - Security check

---

## 📱 **16. APP STORE & PUBLISHING**

### **App Store Guidelines**
- **Apple Compliance** - Full compliance with Apple rules
- **Metadata Optimization** - ASO strategy
- **Screenshot Requirements** - High quality images
- **Review Process** - Apple review process

### **Marketing Assets**
- **App Icon** - High quality app icon
- **Screenshots** - For all device sizes
- **App Preview** - Video introduction
- **Description** - Effective app description

### **Launch Strategy**
- **Soft Launch** - TestFlight beta
- **Public Launch** - App Store release
- **Press Release** - Media announcement
- **Influencer Outreach** - Influencer partnerships

---

## 🎯 **17. SUCCESS CRITERIA & KPIs**

### **North Star Metrics**
- **Weekly Active Readings** - Weekly active fortune readings count
- **User Retention** - 7 days 40%+, 30 days 25%+
- **Conversion Rate** - Free to paid 8%+
- **Social Shares** - 20%+ sharing rate

### **Performance KPIs**
- **App Launch Time** - Under 3 seconds
- **Reading Generation** - Under 10 seconds
- **App Store Rating** - 4.5+ stars
- **Crash Rate** - Under 0.1%

### **Business Metrics**
- **Monthly Recurring Revenue** - $100k (Month 6), $1M (Month 12)
- **Average Revenue Per User** - $3.50/month
- **Customer Acquisition Cost** - Under $5
- **Lifetime Value** - Over $50

---

## 🎨 **18. VİBE CODER WORKFLOW (Solo Development)**

### **AI-Assisted Development**
- **Cursor AI Usage** - For feature scaffolding and boilerplate
- **Code Generation** - AI support for repetitive code
- **Bug Fixing** - AI help in bug fixing
- **Learning Acceleration** - Quickly learning new technologies

### **Efficient Development Practices**
- **Copy-Paste-Adapt** - Reuse proven patterns (BananaUniverse base)
- **Stack Minimalism** - Only what's needed (SwiftUI + Supabase + fal.ai)
- **No Over-Engineering** - If simple solution works, don't make it complex
- **Rapid Prototyping** - Fast prototype development

### **Learning & Growth**
- **Learning Budget** - Learn 1 new thing per sprint, try 10 new things
- **Ask for Help** - Ask when stuck for more than 30 minutes
- **Community Engagement** - Participate in developer communities
- **Knowledge Sharing** - Share what you learn

### **Solo Developer Mindset**
- **Focus on Core** - Focus on core features
- **Iterate Fast** - Fast iteration and learning
- **User Feedback** - Prioritize user feedback
- **Quality over Speed** - Quality over speed

---

## 📋 **19. QUALITY CONTROL CHECKLIST**

### **Pre-Release Checklist**
- [ ] All critical paths tested
- [ ] Performance benchmarks met
- [ ] Accessibility standards achieved
- [ ] Cultural sensitivity check completed
- [ ] Security audit completed
- [ ] User testing performed
- [ ] Documentation updated
- [ ] App Store guidelines checked

### **Weekly Review Checklist**
- [ ] Sprint goals achieved
- [ ] User feedback analyzed
- [ ] Performance metrics checked
- [ ] Bug reports evaluated
- [ ] Next week planning completed
- [ ] Learning goals updated

---

## 🗄️ **20. DATABASE SCHEMA (FORTUNIA)**

### **Core Tables**

```sql
-- USERS TABLE - User profile information
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE,
  birth_date DATE,
  birth_time TIME,
  birth_city TEXT,
  birth_country TEXT,
  timezone TEXT DEFAULT 'UTC',
  language TEXT DEFAULT 'en',
  notification_enabled BOOLEAN DEFAULT FALSE,
  notification_time TIME DEFAULT '09:00:00',
  created_at TIMESTAMP DEFAULT NOW(),
  last_active_at TIMESTAMP DEFAULT NOW()
);

-- READINGS TABLE - All fortune readings
CREATE TABLE readings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  reading_type TEXT NOT NULL, -- 'face', 'palm', 'tarot', 'coffee'
  cultural_origin TEXT NOT NULL, -- 'chinese', 'middle_eastern', 'european'
  image_url TEXT,
  result_text TEXT,
  share_card_url TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- DAILY QUOTAS TABLE - Daily free fortune limit
CREATE TABLE daily_quotas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  date DATE NOT NULL,
  free_readings_used INTEGER DEFAULT 0, -- Max 3 per day
  premium_readings_used INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- SUBSCRIPTIONS TABLE - Adapty subscription data
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  adapty_customer_id TEXT UNIQUE,
  adapty_subscription_id TEXT,
  status TEXT NOT NULL, -- 'active', 'expired', 'cancelled', 'trial'
  product_id TEXT NOT NULL, -- 'weekly', 'monthly', 'yearly'
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### **RLS Policies (Security)**

```sql
-- Enable Row Level Security
ALTER TABLE readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_quotas ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Users can only access their own data
CREATE POLICY "Users can only access own readings"
ON readings FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can only access own quotas"
ON daily_quotas FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can only access own subscriptions"
ON subscriptions FOR ALL USING (auth.uid() = user_id);
```

### **Helper Functions**

```sql
-- Daily quota check
CREATE OR REPLACE FUNCTION check_daily_quota(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  quota_count INTEGER;
BEGIN
  SELECT free_readings_used INTO quota_count
  FROM daily_quotas
  WHERE user_id = p_user_id AND date = CURRENT_DATE;
  
  IF quota_count IS NULL THEN
    INSERT INTO daily_quotas (user_id, date, free_readings_used)
    VALUES (p_user_id, CURRENT_DATE, 0);
    RETURN 0;
  END IF;
  
  RETURN quota_count;
END;
$$ LANGUAGE plpgsql;

-- Increment quota
CREATE OR REPLACE FUNCTION increment_daily_quota(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  INSERT INTO daily_quotas (user_id, date, free_readings_used)
  VALUES (p_user_id, CURRENT_DATE, 1)
  ON CONFLICT (user_id, date)
  DO UPDATE SET free_readings_used = daily_quotas.free_readings_used + 1;
END;
$$ LANGUAGE plpgsql;
```

---

## 🎯 **21. SUCCESS DEFINITION**

### **Technical Success**
- **Stable Performance** - 99.9% uptime
- **Fast Response** - Operations under 3 seconds
- **Zero Critical Bugs** - No critical errors
- **High User Satisfaction** - 4.5+ App Store rating

### **Business Success**
- **User Growth** - 1M users (Year 1)
- **Revenue Growth** - $1M MRR (Year 1)
- **Market Position** - Top 10 Lifestyle apps
- **Cultural Impact** - Global spiritual community

### **Personal Success**
- **Learning Growth** - Continuous learning and development
- **Work-Life Balance** - Healthy work routine
- **Creative Fulfillment** - Creative satisfaction
- **Community Building** - Meaningful community building

---

## 📝 **CONCLUSION**

This General Development Rules document contains the fundamental rules and standards to be followed in the development process of the FORTUNIA application.

**Core Principles:**
- **Simplicity** - Simplicity is the ultimate sophistication
- **Quality** - Quality comes before speed
- **User-First** - User experience is more important than anything else
- **Cultural Respect** - Cultural sensitivity and respect
- **Continuous Learning** - Continuous learning and development

**Success Criteria:**
- Users love and share the app
- Technical performance is perfect
- Accepted by cultural communities
- Sustainable business model

These rules are designed to make FORTUNIA the world's best spiritual guidance platform by combining Steve Jobs' philosophy with modern development practices.

---

**Document Approval:**
- [x] Solo Developer (Vibe Coder)
- [ ] Future Team Members (When Applicable)

**Last Updated:** October 24, 2025

---

*"The people who are crazy enough to think they can change the world are the ones who do." - Steve Jobs*
