# FinTrack - Project Context

## Overview

FinTrack is a Flutter-based personal finance management application using Firebase Authentication and Cloud Firestore.

The application already has an established architecture.

Future features must integrate into the existing project instead of replacing it.

---

# Firestore Structure

Current database structure:

```
Firestore

users/
    {uid}/
        budgets/
        categories/
        transactions/

categories/
```

This structure is considered stable.

Future features must reuse this structure.

Do not redesign or relocate existing collections unless explicitly requested.

---

# Global Categories

The `categories` collection stores default categories shared by the application.

Example:

* Makanan
* Belanja
* Transport
* Gaji

Admins can manage these categories.

Users consume these categories when creating transactions.

---

# User Document

Every user document should contain:

```
uid
name
email

role
status

language
currency

photo_url

created_at
updated_at
last_login
```

Default values:

role = user

status = active

language = en

currency = IDR

---

# Roles

Supported roles:

* Admin
* User

Architecture must support future roles without refactoring.

Never compare roles using raw strings.

Always use enums.

---

# Permissions

Users

* Manage their own budgets
* Manage their own transactions
* Manage their own profile
* View their own statistics

Admins

* Manage users
* Promote or demote roles
* Enable or disable accounts
* Manage global categories
* Access application statistics
* View all user data when necessary

---

# Multi Language

Supported languages:

* English (default)
* Bahasa Indonesia

All visible text must come from localization.

No hardcoded strings.

---

# Development Rules

* Keep current architecture.
* Reuse repositories and services.
* Reuse Firebase integration.
* Avoid duplicated code.
* Follow SOLID principles.
* Preserve backward compatibility.
* Never rewrite working features.
* Keep UI consistent.
* Prefer incremental improvements over large refactors.
