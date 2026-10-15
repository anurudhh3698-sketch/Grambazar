
<!DOCTYPE html>
<html lang="hi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fresh Sabji Mart - Anurudh Singh</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: Arial, sans-serif;
            background: #f5f9f1;
            color: #222;
        }

        header {
            background: #218838;
            color: white;
            padding: 22px 8%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
        }

        header h1 {
            font-size: 27px;
        }

        nav a {
            color: white;
            text-decoration: none;
            margin-left: 18px;
        }

        .hero {
            text-align: center;
            padding: 65px 20px;
            background: #e0f2d7;
        }

        .hero h2 {
            font-size: 36px;
            color: #17692b;
            margin-bottom: 15px;
        }

        .hero p {
            margin-bottom: 22px;
        }

        .search {
            padding: 12px;
            width: min(90%, 400px);
            border: 1px solid #ccc;
            border-radius: 8px;
            font-size: 16px;
        }

        .section {
            padding: 40px 8%;
        }

        .section h2 {
            text-align: center;
            color: #218838;
            margin-bottom: 28px;
        }

        .products {
            display: grid;
            grid-template-columns:
                repeat(auto-fit, minmax(190px, 1fr));
            gap: 22px;
        }

        .card {
            background: white;
            padding: 20px;
            text-align: center;
            border-radius: 14px;
            box-shadow: 0 3px 12px #00000012;
        }

        .card img {
            width: 100%;
            height: 140px;
            object-fit: contain;
            margin-bottom: 12px;
        }

        .card h3 {
            margin-bottom: 10px;
        }

        .price {
            color: #218838;
            font-size: 20px;
            font-weight: bold;
            margin-bottom: 14px;
        }

        button {
            background: #218838;
            color: white;
            border: none;
            padding: 11px 18px;
            border-radius: 7px;
            cursor: pointer;
        }

        button:hover {
            background: #17692b;
        }

        .cart {
            background: white;
            padding: 20px;
            border-radius: 12px;
            margin-top: 25px;
        }

        #cart-items {
            margin: 15px 0;
            line-height: 2;
        }

        footer {
            background: #17692b;
            color: white;
            text-align: center;
            padding: 22px;
            margin-top: 30px;
        }
    </style>
</head>

<body>

<header>
    <h1>🥦 Fresh Sabji Mart</h1>
    <nav>
        <a href="#home">Home</a>
        <a href="#sabji">Sabziyan</a>
        <a href="#cart">Cart 🛒 (<span id="count">0</span>)</a>
    </nav>
</header>

<section class="hero" id="home">
    <h2>Taazi Sabzi, Behtar Sehat!</h2>
    <p>Anurudh Singh ki sabzi shopping website mein aapka swagat hai.</p>
    <input
        class="search"
        id="search"
        type="text"
        placeholder="Sabzi search karein..."
        oninput="searchVegetables()"
    >
</section>

<section class="section" id="sabji">
    <h2>Hamari Taazi Sabziyan 🥕</h2>

    <div class="products" id="products"></div>

    <div class="cart" id="cart">
        <h2>🛒 Aapka Shopping Cart</h2>
        <div id="cart-items">Abhi cart khaali hai.</div>
        <h3>Total: ₹<span id="total">0</span></h3>
        <br>
        <button onclick="checkout()">Order Karein</button>
    </div>
</section>

<footer>
    <p>© 2026 Fresh Sabji Mart | Created by Anurudh Singh</p>
</footer>

<script>
    const vegetables = [
        {
            name: "Tamatar",
            price: 30,
            image: "https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=400"
        },
        {
            name: "Gajar",
            price: 40,
            image: "https://images.unsplash.com/photo-1445282768818-728615cc910a?w=400"
        },
        {
            name: "Broccoli",
            price: 60,
            image: "https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=400"
        },
        {
            name: "Shimla Mirch",
            price: 50,
            image: "https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=400"
        },
        {
            name: "Aloo",
            price: 25,
            image: "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400"
        },
        {
            name: "Pyaaz",
            price: 35,
            image: "https://images.unsplash.com/photo-1508747703725-719777637510?w=400"
        }
    ];

    let cart = [];

    function showVegetables(items = vegetables) {
        const container = document.getElementById("products");
        container.innerHTML = "";

        items.forEach((veg) => {
            const card = document.createElement("div");
            card.className = "card";

            const img = document.createElement("img");
            img.src = veg.image;
            img.alt = veg.name;
            img.loading = "lazy";

            const name = document.createElement("h3");
            name.textContent = veg.name;

            const price = document.createElement("p");
            price.className = "price";
            price.textContent = `₹${veg.price} / kg`;

            const button = document.createElement("button");
            button.textContent = "Add to Cart";
            button.onclick = () => addToCart(veg.name);

            card.append(img, name, price, button);
            container.appendChild(card);
        });
    }

    function addToCart(name) {
        const item = cart.find(veg => veg.name === name);

        if (item) {
            item.quantity++;
        } else {
            const veg = vegetables.find(v => v.name === name);
            cart.push({ ...veg, quantity: 1 });
        }

        updateCart();
    }

    function updateCart() {
        const container = document.getElementById("cart-items");
        container.innerHTML = "";

        let total = 0;
        let count = 0;

        if (cart.length === 0) {
            container.textContent = "Abhi cart khaali hai.";
        }

        cart.forEach(item => {
            total += item.price * item.quantity;
            count += item.quantity;

            const line = document.createElement("p");
            line.textContent =
                `${item.name} × ${item.quantity} = ₹${item.price * item.quantity} `;

            const remove = document.createElement("button");
            remove.textContent = "−";
            remove.onclick = () => {
                item.quantity--;

                if (item.quantity === 0) {
                    cart = cart.filter(v => v.name !== item.name);
                }

                updateCart();
            };

            line.appendChild(remove);
            container.appendChild(line);
        });

        document.getElementById("total").textContent = total;
        document.getElementById("count").textContent = count;
    }

    function searchVegetables() {
        const query = document
            .getElementById("search")
            .value.toLowerCase();

        const filtered = vegetables.filter(veg =>
            veg.name.toLowerCase().includes(query)
        );

        showVegetables(filtered);
    }

    function checkout() {
        if (cart.length === 0) {
            alert("Pehle cart mein sabzi add karein!");
            return;
        }

        alert(
            "Aapka total bill ₹" +
            document.getElementById("total").textContent +
            " hai. Online order ke liye abhi payment system jodna baaki hai."
        );
    }

    showVegetables();
</script>

</body>
</html>
