const API_BASE = "http://localhost:5002/api";
let allProducts = [];

document.addEventListener("DOMContentLoaded", () => {
  fetchProducts();
  loadDropdowns();
  loadCategoryTable();
  loadBrandTable();
});

// --- NAVIGATION ---
function showSection(sectionId) {
  const sections = [
    "dashboard",
    "add-product",
    "categories",
    "brands",
    "users",
  ];
  sections.forEach((id) => {
    document.getElementById(`section-${id}`).classList.add("hidden");
    const navLink = document.getElementById(`nav-${id}`);
    if (navLink) navLink.classList.remove("active");
  });
  document.getElementById(`section-${sectionId}`).classList.remove("hidden");
  const activeNav = document.getElementById(`nav-${sectionId}`);
  if (activeNav) activeNav.classList.add("active");

  if (sectionId === "users") fetchUsers();
}

// --- PRODUCT MANAGEMENT ---
async function fetchProducts() {
  try {
    const res = await fetch(`${API_BASE}/products`);
    allProducts = await res.json();
    displayProducts(allProducts);
  } catch (err) {
    console.error(err);
  }
}

function displayProducts(products) {
  const tbody = document.getElementById("product-list");
  tbody.innerHTML = products
    .map(
      (p) => `
        <tr>
            <td><img src="${p.image_url}" width="40" height="40" class="rounded"></td>
            <td><strong>${p.name}</strong></td>
            <td><span class="badge bg-info text-dark">${p.brand ? p.brand.name : "-"}</span></td>
            <td><span class="badge bg-secondary">${p.category ? p.category.name : "-"}</span></td>
            <td>$${p.price.toFixed(2)}</td>
            <td>${p.stock_count}</td>
            <td class="text-end">
                <button class="btn btn-sm btn-light" onclick="prepEdit('${p._id}')"><i class="bi bi-pencil"></i></button>
                <button class="btn btn-sm btn-light text-danger" onclick="deleteProduct('${p._id}')"><i class="bi bi-trash"></i></button>
            </td>
        </tr>
    `,
    )
    .join("");
}

async function addProduct() {
  const id = document.getElementById("pId").value;
  const productData = {
    name: document.getElementById("pName").value,
    price: parseFloat(document.getElementById("pPrice").value),
    category: document.getElementById("pCategory").value,
    brand: document.getElementById("pBrand").value,
    stock_count: parseInt(document.getElementById("pStock").value),
    image_url: document.getElementById("pImage").value,
    description: document.getElementById("pDesc").value,
    is_trending: document.getElementById("pTrending").checked,
  };

  const url = id ? `${API_BASE}/products/${id}` : `${API_BASE}/products`;
  const method = id ? "PUT" : "POST";

  try {
    const res = await fetch(url, {
      method,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(productData),
    });

    if (res.ok) {
      alert(id ? "Product updated!" : "Product added successfully!");
      resetProductForm();
      fetchProducts();
      showSection("dashboard");
    }
  } catch (err) {
    console.error("Error saving product:", err);
  }
}

function prepEdit(id) {
  const p = allProducts.find((x) => x._id === id);
  showSection("add-product");
  document.getElementById("pId").value = p._id;
  document.getElementById("pName").value = p.name;
  document.getElementById("pPrice").value = p.price;
  document.getElementById("pStock").value = p.stock_count;
  document.getElementById("pCategory").value = p.category ? p.category._id : "";
  document.getElementById("pBrand").value = p.brand ? p.brand._id : "";
  document.getElementById("pImage").value = p.image_url;
  document.getElementById("pDesc").value = p.description || "";
  document.getElementById("pTrending").checked = p.is_trending;
  document.getElementById("btn-product-action").innerText = "Update Product";
  document.getElementById("btn-cancel-edit").classList.remove("hidden");
}

function resetProductForm() {
  document.getElementById("pId").value = "";
  document.getElementById("pName").value = "";
  document.getElementById("pPrice").value = "";
  document.getElementById("pStock").value = "";
  document.getElementById("pImage").value = "";
  document.getElementById("pDesc").value = "";
  document.getElementById("pCategory").selectedIndex = 0;
  document.getElementById("pBrand").selectedIndex = 0;
  document.getElementById("pTrending").checked = false;
  document.getElementById("btn-product-action").innerText = "Save Product";
  document.getElementById("btn-cancel-edit").classList.add("hidden");
}

async function deleteProduct(id) {
  if (confirm("លុបទំនិញនេះ?")) {
    await fetch(`${API_BASE}/products/${id}`, { method: "DELETE" });
    fetchProducts();
  }
}

// --- USER MANAGEMENT (UPDATED) ---
async function fetchUsers() {
  const res = await fetch(`${API_BASE}/auth/users`);
  const users = await res.json();
  document.getElementById("user-list").innerHTML = users
    .map(
      (u) => `
        <tr>
            <td>${u.name}</td>
            <td>${u.email}</td>
            <td>$${(u.wallet_balance || 0).toFixed(2)}</td>
            <td class="text-end">
                <button class="btn btn-sm btn-outline-primary" onclick="prepEditUser('${u._id}', '${u.name}', '${u.email}')"><i class="bi bi-pencil"></i></button>
                <button class="btn btn-sm btn-outline-danger" onclick="deleteUser('${u._id}')"><i class="bi bi-trash"></i></button>
            </td>
        </tr>
    `,
    )
    .join("");
}

function openCreateUserModal() {
  document.getElementById("createUserModal").classList.remove("hidden");
}
function closeCreateUserModal() {
  document.getElementById("createUserModal").classList.add("hidden");
  document.getElementById("newUserName").value = "";
  document.getElementById("newUserEmail").value = "";
  document.getElementById("newUserPassword").value = "";
}

async function createNewUser() {
  const name = document.getElementById("newUserName").value;
  const email = document.getElementById("newUserEmail").value;
  const password = document.getElementById("newUserPassword").value;

  if (!name || !email || !password) {
    alert("សូមបំពេញព័ត៌មានឱ្យបានគ្រប់គ្រាន់!");
    return;
  }

  try {
    const res = await fetch(`${API_BASE}/auth/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name, email, password }),
    });

    if (res.ok) {
      alert("បង្កើតគណនីជោគជ័យ!");
      closeCreateUserModal();
      fetchUsers();
    } else {
      const error = await res.json();
      alert("បរាជ័យ: " + (error.message || "មានបញ្ហាអ្វីមួយ"));
    }
  } catch (err) {
    console.error("Create user error:", err);
  }
}

function prepEditUser(id, name, email) {
  document.getElementById("editUserId").value = id;
  document.getElementById("editUserName").value = name;
  document.getElementById("editUserEmail").value = email;
  document.getElementById("userModal").classList.remove("hidden");
}

function closeUserModal() {
  document.getElementById("userModal").classList.add("hidden");
}

async function updateUser() {
  const id = document.getElementById("editUserId").value;
  const name = document.getElementById("editUserName").value;
  const email = document.getElementById("editUserEmail").value;
  await fetch(`${API_BASE}/auth/update/${id}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name, email }),
  });
  closeUserModal();
  fetchUsers();
}

async function deleteUser(id) {
  if (confirm("លុបអ្នកប្រើប្រាស់នេះ?")) {
    try {
      const res = await fetch(`${API_BASE}/auth/${id}`, {
        method: "DELETE",
      });

      if (res.ok) {
        alert("លុបបានជោគជ័យ!");
        fetchUsers(); // ហៅមកបង្ហាញបញ្ជីថ្មីឡើងវិញ
      } else {
        alert("មិនអាចលុបបានទេ!");
      }
    } catch (err) {
      console.error("Delete user error:", err);
    }
  }
}

// --- CATEGORY & BRAND (REMAINING FUNCTIONS) ---
async function addCategory() {
  const name = document.getElementById("newCatName").value;
  await fetch(`${API_BASE}/categories`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name }),
  });
  document.getElementById("newCatName").value = "";
  loadCategoryTable();
  loadDropdowns();
}

async function addBrand() {
  const name = document.getElementById("newBrandName").value;
  await fetch(`${API_BASE}/brands`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name }),
  });
  document.getElementById("newBrandName").value = "";
  loadBrandTable();
  loadDropdowns();
}

async function deleteItem(route, id) {
  if (confirm("លុបវាពិតមែនទេ?")) {
    await fetch(`${API_BASE}/${route}/${id}`, { method: "DELETE" });
    if (route === "categories") loadCategoryTable();
    else loadBrandTable();
    loadDropdowns();
  }
}

async function loadCategoryTable() {
  const res = await fetch(`${API_BASE}/categories`);
  const cats = await res.json();
  document.getElementById("category-table-body").innerHTML = cats
    .map(
      (c) =>
        `<tr><td>${c.name}</td><td class="text-end"><button class="btn btn-sm btn-outline-danger" onclick="deleteItem('categories', '${c._id}')">Delete</button></td></tr>`,
    )
    .join("");
}

async function loadBrandTable() {
  const res = await fetch(`${API_BASE}/brands`);
  const brands = await res.json();
  document.getElementById("brand-table-body").innerHTML = brands
    .map(
      (b) =>
        `<tr><td>${b.name}</td><td class="text-end"><button class="btn btn-sm btn-outline-danger" onclick="deleteItem('brands', '${b._id}')">Delete</button></td></tr>`,
    )
    .join("");
}

async function loadDropdowns() {
  const [catRes, brandRes] = await Promise.all([
    fetch(`${API_BASE}/categories`),
    fetch(`${API_BASE}/brands`),
  ]);
  const cats = await catRes.json();
  const brands = await brandRes.json();
  document.getElementById("pCategory").innerHTML = cats
    .map((c) => `<option value="${c._id}">${c.name}</option>`)
    .join("");
  document.getElementById("pFilterCategory").innerHTML =
    '<option value="All">All Categories</option>' +
    cats.map((c) => `<option value="${c.name}">${c.name}</option>`).join("");
  document.getElementById("pBrand").innerHTML = brands
    .map((b) => `<option value="${b._id}">${b.name}</option>`)
    .join("");
}

function filterProducts() {
  const term = document.getElementById("pSearch").value.toLowerCase();
  const cat = document.getElementById("pFilterCategory").value;
  const filtered = allProducts.filter((p) => {
    const matchSearch = p.name.toLowerCase().includes(term);
    const matchCat = cat === "All" || (p.category && p.category.name === cat);
    return matchSearch && matchCat;
  });
  displayProducts(filtered);
}
