const API_BASE = "http://localhost:5001/api";
let allProducts = [];

// --- NAVIGATION ---
function showSection(sectionId) {
  document.getElementById("section-dashboard").classList.add("hidden");
  document.getElementById("section-users").classList.add("hidden");
  document.getElementById("section-products").classList.add("hidden");

  document
    .querySelectorAll(".nav-link")
    .forEach((l) => l.classList.remove("active"));

  document.getElementById("section-" + sectionId).classList.remove("hidden");
  document.getElementById("nav-" + sectionId).classList.add("active");

  if (sectionId === "users") fetchUsers();
  if (sectionId === "products") fetchProducts();
}

// --- USER ACTIONS ---
async function fetchUsers() {
  const res = await fetch(`${API_BASE}/auth/users`);
  const users = await res.json();
  document.getElementById("user-list").innerHTML = users
    .map(
      (u) => `
        <tr><td>${u.name}</td><td>${u.email}</td><td>$${u.wallet_balance.toFixed(2)}</td></tr>
    `,
    )
    .join("");
}

async function addUser() {
  const data = {
    name: document.getElementById("uName").value,
    email: document.getElementById("uEmail").value,
    password: document.getElementById("uPass").value,
  };
  const res = await fetch(`${API_BASE}/auth/register`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });
  if (res.ok) {
    alert("User Added!");
    location.reload();
  }
}

// --- PRODUCT ACTIONS ---
async function fetchProducts() {
  const res = await fetch(`${API_BASE}/products`);
  allProducts = await res.json();
  renderProducts(allProducts);
}

function renderProducts(data) {
  document.getElementById("product-list").innerHTML = data
    .map(
      (p) => `
        <tr>
            <td><img src="${p.image_url}" width="45" height="45"></td>
            <td>${p.name}</td>
            <td><span class="badge bg-secondary">${p.category}</span></td>
            <td>$${p.price.toFixed(2)}</td>
            <td>${p.stock_count}</td>
            <td class="text-end">
                <button class="btn btn-sm btn-outline-primary me-1" onclick="prepEdit('${p._id}')"><i class="bi bi-pencil"></i></button>
                <button class="btn btn-sm btn-outline-danger" onclick="deleteProduct('${p._id}')"><i class="bi bi-trash"></i></button>
            </td>
        </tr>
    `,
    )
    .join("");
}

function filterProducts() {
  const q = document.getElementById("pSearch").value.toLowerCase();
  const cat = document.getElementById("pFilterCategory").value;
  const filtered = allProducts.filter(
    (p) =>
      p.name.toLowerCase().includes(q) && (cat === "All" || p.category === cat),
  );
  renderProducts(filtered);
}

async function addProduct() {
  const id = document.getElementById("pId").value;
  const data = {
    name: document.getElementById("pName").value,
    price: parseFloat(document.getElementById("pPrice").value),
    category: document.getElementById("pCategory").value,
    stock_count: parseInt(document.getElementById("pStock").value),
    image_url: document.getElementById("pImage").value,
    description: document.getElementById("pDesc").value,
    is_trending: document.getElementById("pTrending").checked,
  };

  const url = id ? `${API_BASE}/products/${id}` : `${API_BASE}/products`;
  const method = id ? "PUT" : "POST";

  const res = await fetch(url, {
    method: method,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });

  if (res.ok) {
    alert(id ? "Product Updated!" : "Product Created!");
    location.reload();
  }
}

async function deleteProduct(id) {
  if (confirm("Delete this product?")) {
    await fetch(`${API_BASE}/products/${id}`, { method: "DELETE" });
    fetchProducts();
  }
}

function prepEdit(id) {
  const p = allProducts.find((x) => x._id === id);
  showSection("dashboard");
  document.getElementById("pId").value = p._id;
  document.getElementById("pName").value = p.name;
  document.getElementById("pPrice").value = p.price;
  document.getElementById("pCategory").value = p.category;
  document.getElementById("pStock").value = p.stock_count;
  document.getElementById("pImage").value = p.image_url;
  document.getElementById("pDesc").value = p.description || "";
  document.getElementById("pTrending").checked = p.is_trending;

  document.getElementById("btn-product-action").innerText = "Update Product";
  document.getElementById("btn-cancel-edit").classList.remove("hidden");
}

function resetProductForm() {
  location.reload();
}
