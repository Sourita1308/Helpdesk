<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="header.jsp">
    <jsp:param name="title" value="Register IT Asset" />
    <jsp:param name="subtitle" value="Add new hardware device or software license to corporate register" />
    <jsp:param name="active" value="assets" />
</jsp:include>

<div class="card" style="max-width: 860px; margin: 0 auto;">
    <div class="card-header">
        <div class="card-title">
            <i data-lucide="package-plus" class="icon-md" style="color: #818cf8;"></i>
            <span>Asset Registration Form</span>
        </div>
        <a href="${pageContext.request.contextPath}/assets" class="btn btn-secondary btn-sm">Cancel</a>
    </div>
    <div class="card-body">
        <form action="${pageContext.request.contextPath}/assets/new" method="post">
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label" for="assetTag">Asset Tag ID *</label>
                    <input type="text" id="assetTag" name="assetTag" class="input-control" required placeholder="e.g. HW-LAP-105 or SW-LIC-304" style="width: 100%;" />
                </div>
                <div class="form-group">
                    <label class="form-label" for="name">Asset Model / Name *</label>
                    <input type="text" id="name" name="name" class="input-control" required placeholder="e.g. Lenovo ThinkPad T14s Gen 4" style="width: 100%;" />
                </div>
                <div class="form-group">
                    <label class="form-label" for="type">Asset Type *</label>
                    <select id="type" name="type" class="select-control" required style="width: 100%;">
                        <option value="Hardware">Hardware (Physical Equipment)</option>
                        <option value="Software">Software (License / Subscription)</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" for="category">Category *</label>
                    <select id="category" name="category" class="select-control" required style="width: 100%;">
                        <option value="Laptop">Laptop</option>
                        <option value="Desktop">Desktop Workstation</option>
                        <option value="Monitor">Monitor / Display</option>
                        <option value="License">Software License</option>
                        <option value="Peripherals">Peripherals / Accessories</option>
                        <option value="Mobile">Mobile Device / Tablet</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" for="serialNumber">Serial Number / License Key</label>
                    <input type="text" id="serialNumber" name="serialNumber" class="input-control" placeholder="e.g. SN-LNV-88291X" style="width: 100%;" />
                </div>
                <div class="form-group">
                    <label class="form-label" for="status">Current Status</label>
                    <select id="status" name="status" class="select-control" style="width: 100%;">
                        <option value="Allocated">Allocated to Employee</option>
                        <option value="In Stock">In Stock / Pool</option>
                        <option value="Under Repair">Under Repair</option>
                        <option value="Retired">Retired / Decommissioned</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" for="assignedUserId">Allocate To Employee</label>
                    <select id="assignedUserId" name="assignedUserId" class="select-control" style="width: 100%;">
                        <option value="">-- Unallocated (Store in IT Inventory) --</option>
                        <c:forEach var="u" items="${users}">
                            <option value="${u.id}">${u.name} (${u.department})</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" for="purchaseDate">Purchase Date</label>
                    <input type="date" id="purchaseDate" name="purchaseDate" class="input-control" style="width: 100%;" />
                </div>
                <div class="form-group">
                    <label class="form-label" for="warrantyExpiry">Warranty / Renewal Expiry</label>
                    <input type="date" id="warrantyExpiry" name="warrantyExpiry" class="input-control" style="width: 100%;" />
                </div>
                <div class="form-group full-width">
                    <label class="form-label" for="specsOrLicense">Hardware Specs / Provisioning Notes</label>
                    <textarea id="specsOrLicense" name="specsOrLicense" class="input-control form-textarea" placeholder="RAM, CPU, Storage, GPU, MAC Address or License SKU details..." style="width: 100%;"></textarea>
                </div>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 16px;">
                <a href="${pageContext.request.contextPath}/assets" class="btn btn-secondary">Cancel</a>
                <button type="submit" class="btn btn-primary">
                    <i data-lucide="check" class="icon-sm"></i>
                    <span>Save to Register</span>
                </button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="footer.jsp" />
