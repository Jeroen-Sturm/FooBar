# Grant Access to Event Hub — Readme

## 1️⃣ What is Bicep?

[Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview) is a **domain-specific language for deploying Azure resources**.  
- Simplifies ARM templates.  
- Makes infrastructure-as-code readable and maintainable.  
- Bicep files (`.bicep`) compile into ARM JSON templates (`.json`) that Azure can deploy.

---

## 2️⃣ What does this Bicep do?

This template automates **granting a partner access to an existing Azure Event Hub namespace**:  

- Creates a **Shared Access Policy (SAS rule)** in the specified namespace.  
- Allows you to select the **rights** (`Send`, `Listen`, or both).  
- Outputs the **primary connection string** for the partner to use.  
- Automatically uses the **existing namespace’s location**.

**You only need to provide:**  
- `eventHubName`: Name of the existing Event Hub namespace.  
- Optionally `policyName` and `rights`.

---

## 3️⃣ Where to host Bicep and JSON

To make a **public Deploy-to-Azure button**:

1. Host your `.bicep` or `.json` files in a **public GitHub repository**.  
2. Only `.json` file is supported by Azure as of right now.
3. Use the **raw file URL** in the Deploy button:

```
https://raw.githubusercontent.com/<username>/<repo>/main/<file>.json
```

- **Ensure it’s raw text, not an HTML preview.**  
- For guaranteed compatibility, compile Bicep to JSON first.

---

## 4️⃣ How to convert Bicep to JSON

1. Install [Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install) (Windows, macOS, Linux).  
2. Run:

```bash
bicep build grant-access-to-partner.bicep
```

- This produces `grant-access-to-partner.json`.  
- Use `.json` for the Deploy button for maximum compatibility.

---

## 5️⃣ Using the Deploy-to-Azure Button

Example:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2F<username>%2F<repo>%2Fmain%2Fgrant-access-to-partner.json)

- Click the button → Azure Portal opens → template preloaded.  
- Fill in parameters: `namespaceName`, `policyName`, `rights`.  
- Deploy → outputs connection string for the partner.
- Output Tab is not shown by default you need to click it.

---

## 6️⃣ Tips for Partners

- Use **exact namespace names** — case-sensitive, no spaces.
- Copy the **connection string** securely to the integration partner.

---

