# HelpDesk Lite — Internal IT Ticketing & Asset Tracker

> **Built with**: Java 17+ · Jakarta Servlets / JSP · JDBC · MySQL 8.0 · Apache Tomcat 10

Enterprise first-line and second-line IT operations workflow system, modelling a real IT helpdesk queue end to end with hardware/software asset allocation and repeat-issue failure analysis.

---

## 🌟 Key Features

### 1. First-Line Support Workflow
- **Ticket Intake**: Full ticketing pipeline with category tagging (`Hardware`, `Software`, `Network`, `Access & Security`, `Infrastructure`) and priority scoring (`Low`, `Medium`, `High`, `Critical`).
- **Dynamic SLA Timers**: Real-time SLA countdown clocks ticking down in browser:
  - **Critical**: 2-Hour SLA
  - **High**: 4-Hour SLA
  - **Medium**: 8-Hour SLA
  - **Low**: 24-Hour SLA
  - Visual status pill indicators: `Normal`, `Warning (<2h)`, `Urgent (<1h)`, and `Breached`.
- **Assignment & Resolution Notes**: Assign to First-Line (L1) agents, track progress status, and record detailed technical resolution notes.

### 2. Asset Register & Repeat-Issue Analysis
- **Hardware & Software Allocation**: Track laptops, desktops, monitors, peripherals, and software licenses allocated per employee.
- **Service & Maintenance History**: Log installation imaging, driver fixes, battery replacements, and OS recovery with technician audit trails and cost tracking.
- **Repeat-Issue Analysis Engine**: Automatically analyzes and flags equipment logging multiple incidents ($\ge 2$ tickets) to isolate chronic hardware degradation and recommend RMA replacements.

### 3. Escalation Rules & Knowledge Base
- **Tier Routing (L1 &rarr; L2)**: Route unresolved, breached, or complex issues to Second-Line engineering specialists (`Marcus Vance`, `Elena Rostova`) with mandatory justification audit logs.
- **Automated SLA Escalation Engine**: 1-click or automated rule execution that evaluates stalled/breached tickets and assigns them to Tier-2 engineers.
- **Knowledge Base Runbooks**: Searchable repository of verified solutions and error runbooks.
- **1-Click Ticket-to-KB Converter**: Turn any resolved incident into a reusable Knowledge Base guide with symptoms, root cause, and step-by-step resolution.

---

## 🚀 Quick Start (1-Click Run)

### Option 1: Double-Click `run.bat`
Simply run `run.bat` in the project root:
```bat
run.bat
```
The server will start embedded Apache Tomcat and listen on:
```
http://localhost:8080/dashboard
```

### Option 2: Command Line via Maven Wrapper
```cmd
.\mvnw.cmd exec:java
```

---

## 🌐 Deploy Anywhere (Cloud, Docker & Tomcat)

HelpDesk Lite is architected to deploy anywhere seamlessly with **zero external dependencies required** (auto-seeds embedded database if no external database is connected) or with a production **MySQL 8.0** cluster.

### 1. Free Cloud Hosting: Render.com (Recommended)
1. Push this project to your GitHub repository.
2. Go to [Render.com](https://render.com) and click **New +** &rarr; **Web Service**.
3. Connect your GitHub repository.
4. Render will automatically detect the [`Dockerfile`](Dockerfile) or [`render.yaml`](render.yaml):
   - **Environment**: Docker
   - **Plan**: Free
5. Click **Deploy Web Service** — Render automatically builds and hosts your app with a public HTTPS URL (e.g., `https://helpdesk-lite.onrender.com/dashboard`)!

### 2. Free / Low-Cost Cloud: Railway.app
1. Go to [Railway.app](https://railway.app) and create a **New Project**.
2. Select **Deploy from GitHub repo** and pick your repository.
3. Railway will build the container from `Dockerfile` automatically and assign an HTTP domain.
4. *(Optional)* Click **+ New** &rarr; **Database** &rarr; **Add MySQL** on Railway to get persistent cloud MySQL storage. Railway automatically provides `MYSQL_URL` which HelpDesk Lite auto-detects and connects to!

### 3. Docker & Docker Compose (Any VPS or Server)
Run the full stack with dedicated MySQL 8 container in one command:
```bash
docker compose up --build -d
```
Access the application at `http://localhost:8080/dashboard`.

Or run the lightweight standalone container:
```bash
docker build -t helpdesk-lite .
docker run -d -p 8080:8080 -e PORT=8080 --name helpdesk helpdesk-lite
```

### 4. Traditional Tomcat 10+ (WAR Deployment)
Deploy to standard Apache Tomcat on any Windows Server, Linux VPS, or AWS Elastic Beanstalk:
1. Build the production WAR package:
   ```cmd
   .\mvnw.cmd clean package -DskipTests
   ```
2. Copy the resulting file:
   ```
   target/helpdesk-lite.war  -->  <TOMCAT_HOME>/webapps/ROOT.war
   ```
3. Start Tomcat:
   - Linux: `<TOMCAT_HOME>/bin/startup.sh`
   - Windows: `<TOMCAT_HOME>\bin\startup.bat`
4. Access via your server's domain or `http://your-server-ip:8080/dashboard`.

---

## 🗄️ Database Configuration & Cloud Env Vars

The application supports automatic zero-setup embedded storage as well as cloud-managed MySQL instances via standard environment variables:

| Environment Variable | Description | Example |
| :--- | :--- | :--- |
| `DATABASE_URL` or `MYSQL_URL` | Full JDBC or standard MySQL URI | `mysql://user:pass@host:3306/db` |
| `MYSQL_HOST` / `DB_HOST` | Database Hostname / IP | `mysql.railway.internal` or `localhost` |
| `MYSQL_PORT` / `DB_PORT` | Database Port (default 3306) | `3306` |
| `MYSQL_DATABASE` / `DB_NAME`| Database Name | `helpdesk_db` |
| `MYSQL_USER` / `DB_USER` | Username | `root` or `helpdesk_user` |
| `MYSQL_PASSWORD` / `DB_PASSWORD` | Password | `secret123` |
| `PORT` | Dynamic web port (handled automatically) | `8080` or `10000` |

If no database environment variables are set and local MySQL is not reachable, HelpDesk Lite automatically activates its **Embedded MySQL 8.0-Compatible Engine** with initial seed data, guaranteeing zero downtime and zero deployment failures.

---

## 📁 Project Structure

```
HelpDesk Lite
├── src/main/java/com/helpdesk/
│   ├── App.java                   # Embedded Apache Tomcat launcher
│   ├── model/                     # Core Domain Entities
│   │   ├── User.java              # IT Agents (L1/L2) & Employees
│   │   ├── Asset.java             # Hardware & Software Assets
│   │   ├── Ticket.java            # Tickets with live SLA metrics
│   │   ├── MaintenanceLog.java    # Service and installation logs
│   │   ├── EscalationLog.java     # Routing audit trail
│   │   └── KbArticle.java          # Knowledge base guides
│   ├── dao/                       # Data Access Layer (JDBC + Connection Pool)
│   │   ├── DBUtil.java            # HikariCP connection pool & DB bootstrap
│   │   ├── UserDAO.java           # IT staff & users
│   │   ├── AssetDAO.java          # Assets & repeat-issue queries
│   │   ├── MaintenanceDAO.java    # Service history
│   │   ├── TicketDAO.java         # Queue filters & SLA calculation
│   │   └── KbDAO.java             # Search & conversion engine
│   ├── service/
│   │   └── EscalationService.java # Automated SLA breach rules & L2 routing
│   └── servlet/                   # Jakarta Servlets (Controllers)
│       ├── DashboardServlet.java  # /dashboard metrics & overview
│       ├── TicketServlet.java     # /tickets (intake, triage, resolve)
│       ├── AssetServlet.java      # /assets (register, repeat-issues)
│       ├── EscalationServlet.java # /escalate (manual & automated L2)
│       └── KbServlet.java         # /kb (search, runbooks, converter)
├── src/main/webapp/
│   ├── css/style.css              # Custom IT dark/light design system
│   ├── js/app.js                  # Live SLA countdown ticker
│   └── WEB-INF/
│       ├── web.xml                # Servlet declarations & JSTL config
│       ├── tld/                   # JSTL Core & Fmt TLDs
│       └── views/                 # JSP Presentation Layer
│           ├── header.jsp         # Sidebar navigation & actions
│           ├── footer.jsp         # Common footer & scripts
│           ├── dashboard.jsp      # IT Operations overview
│           ├── tickets.jsp        # Helpdesk queues & filters
│           ├── ticket-new.jsp     # Intake & SLA tagger
│           ├── ticket-detail.jsp  # Triage, SLA timer, L2 escalation
│           ├── assets.jsp         # Hardware & software register
│           ├── asset-new.jsp      # Register new asset
│           ├── asset-detail.jsp   # Maintenance & repeat-issue logs
│           ├── repeat-issues.jsp  # High-incidence equipment diagnostic
│           ├── kb.jsp             # Knowledge Base catalog & search
│           ├── kb-detail.jsp      # Resolution runbooks
│           └── kb-new.jsp         # 1-Click Ticket-to-KB publisher
├── pom.xml                        # Maven dependencies & build plugins
├── run.bat                        # 1-click Windows runner
└── mvnw.cmd                       # Maven wrapper
```
