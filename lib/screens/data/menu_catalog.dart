/// Starter menu catalog for AFZ Restaurant.
/// Keep menu item data here so it can be seeded into Firestore in one place.
const List<Map<String, dynamic>> afzStarterMenu = [
  // Burgers (6)
  {
    'name': 'Classic Beef Burger',
    'category': 'Burgers',
    'price': 850,
    'image':
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80',
    'description':
        'Juicy beef patty with fresh lettuce, tomato and special sauce.',
  },
  {
    'name': 'Chicken Burger',
    'category': 'Burgers',
    'price': 750,
    'image':
        'https://images.unsplash.com/photo-1606755962773-d324e0a13086?auto=format&fit=crop&w=800&q=80',
    'description':
        'Crispy chicken fillet with lettuce, cheese and creamy sauce.',
  },
  {
    'name': 'Zinger Burger',
    'category': 'Burgers',
    'price': 800,
    'image':
        'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?auto=format&fit=crop&w=800&q=80',
    'description':
        'Crispy spicy chicken burger with fresh vegetables and sauce.',
  },
  {
    'name': 'Cheese Beef Burger',
    'category': 'Burgers',
    'price': 950,
    'image':
        'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9?auto=format&fit=crop&w=800&q=80',
    'description':
        'Double cheese and juicy beef patty with our signature sauce.',
  },
  {
    'name': 'Double Beef Burger',
    'category': 'Burgers',
    'price': 1150,
    'image':
        'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=800&q=80',
    'description': 'Two delicious beef patties with cheese and fresh toppings.',
  },
  {
    'name': 'BBQ Chicken Burger',
    'category': 'Burgers',
    'price': 900,
    'image':
        'https://images.unsplash.com/photo-1606755962773-d324e0a13086?auto=format&fit=crop&w=800&q=80',
    'description':
        'Grilled chicken with smoky BBQ sauce and crunchy vegetables.',
  },

  // Pizza (6)
  {
    'name': 'Cheese Pizza',
    'category': 'Pizza',
    'price': 1200,
    'image':
        'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=800&q=80',
    'description':
        'Classic pizza loaded with mozzarella cheese and tomato sauce.',
  },
  {
    'name': 'Pepperoni Pizza',
    'category': 'Pizza',
    'price': 1450,
    'image':
        'https://images.unsplash.com/photo-1628840042765-356cda07504e?auto=format&fit=crop&w=800&q=80',
    'description':
        'Classic pepperoni with mozzarella cheese and rich tomato sauce.',
  },
  {
    'name': 'Chicken Tikka Pizza',
    'category': 'Pizza',
    'price': 1400,
    'image':
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80',
    'description': 'Chicken tikka, onions, capsicum and mozzarella cheese.',
  },
  {
    'name': 'BBQ Chicken Pizza',
    'category': 'Pizza',
    'price': 1500,
    'image':
        'https://images.unsplash.com/photo-1579751626657-72bc17010498?auto=format&fit=crop&w=800&q=80',
    'description': 'Smoky BBQ chicken with onions, cheese and BBQ sauce.',
  },
  {
    'name': 'Fajita Pizza',
    'category': 'Pizza',
    'price': 1550,
    'image':
        'https://images.unsplash.com/photo-1593560708920-61dd98c8a7c8?auto=format&fit=crop&w=800&q=80',
    'description': 'Spicy chicken fajita with capsicum, onions and cheese.',
  },
  {
    'name': 'Vegetable Pizza',
    'category': 'Pizza',
    'price': 1150,
    'image':
        'https://images.unsplash.com/photo-1579751626657-72bc17010498?auto=format&fit=crop&w=800&q=80',
    'description': 'Fresh capsicum, onions, tomatoes, olives and mozzarella.',
  },

  // Rice (5)
  {
    'name': 'Chicken Biryani',
    'category': 'Rice',
    'price': 450,
    'image':
        'https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&w=800&q=80',
    'description':
        'Traditional Pakistani chicken biryani with aromatic basmati rice.',
  },
  {
    'name': 'Beef Biryani',
    'category': 'Rice',
    'price': 550,
    'image':
        'https://images.unsplash.com/photo-1563379091339-03246963d96c?auto=format&fit=crop&w=800&q=80',
    'description': 'Spicy beef biryani prepared with aromatic spices.',
  },
  {
    'name': 'Mutton Biryani',
    'category': 'Rice',
    'price': 650,
    'image':
        'https://images.unsplash.com/photo-1631515242808-497c3fbd3972?auto=format&fit=crop&w=800&q=80',
    'description':
        'Tender mutton with fragrant basmati rice and traditional spices.',
  },
  {
    'name': 'Chicken Pulao',
    'category': 'Rice',
    'price': 450,
    'image':
        'https://images.unsplash.com/photo-1596797038530-2c107229654b?auto=format&fit=crop&w=800&q=80',
    'description': 'Light and flavorful chicken pulao with aromatic rice.',
  },
  {
    'name': 'Beef Pulao',
    'category': 'Rice',
    'price': 550,
    'image':
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80',
    'description': 'Tender beef cooked with flavorful basmati rice and spices.',
  },

  // BBQ (5)
  {
    'name': 'BBQ Platter',
    'category': 'BBQ',
    'price': 1800,
    'image':
        'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',
    'description':
        'A delicious combination of grilled chicken, kebabs and BBQ items.',
  },
  {
    'name': 'Chicken Tikka',
    'category': 'BBQ',
    'price': 650,
    'image':
        'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?auto=format&fit=crop&w=800&q=80',
    'description':
        'Tender chicken pieces marinated with traditional spices and grilled.',
  },
  {
    'name': 'Chicken Seekh Kebab',
    'category': 'BBQ',
    'price': 600,
    'image':
        'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?auto=format&fit=crop&w=800&q=80',
    'description': 'Juicy minced chicken kebabs grilled to perfection.',
  },
  {
    'name': 'Beef Seekh Kebab',
    'category': 'BBQ',
    'price': 700,
    'image':
        'https://images.unsplash.com/photo-1529042410759-befb1204b468?auto=format&fit=crop&w=800&q=80',
    'description':
        'Traditional spicy beef seekh kebabs served hot from the grill.',
  },
  {
    'name': 'Malai Boti',
    'category': 'BBQ',
    'price': 850,
    'image':
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80',
    'description': 'Creamy and tender chicken pieces grilled with mild spices.',
  },

  // Fast Food (5)
  {
    'name': 'Chicken Shawarma',
    'category': 'Fast Food',
    'price': 450,
    'image':
        'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?auto=format&fit=crop&w=800&q=80',
    'description':
        'Juicy chicken wrapped with fresh vegetables and garlic sauce.',
  },
  {
    'name': 'Chicken Wrap',
    'category': 'Fast Food',
    'price': 500,
    'image':
        'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=800&q=80',
    'description':
        'Grilled chicken, vegetables and creamy sauce wrapped in soft bread.',
  },
  {
    'name': 'Chicken Nuggets',
    'category': 'Fast Food',
    'price': 550,
    'image':
        'https://images.unsplash.com/photo-1562967916-eb82221dfb92?auto=format&fit=crop&w=800&q=80',
    'description': 'Crispy golden chicken nuggets served with dipping sauce.',
  },
  {
    'name': 'French Fries',
    'category': 'Fast Food',
    'price': 300,
    'image':
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=800&q=80',
    'description':
        'Crispy golden fries lightly seasoned with our special seasoning.',
  },
  {
    'name': 'Loaded Fries',
    'category': 'Fast Food',
    'price': 550,
    'image':
        'https://images.unsplash.com/photo-1585109649139-366815a0d713?auto=format&fit=crop&w=800&q=80',
    'description':
        'Crispy fries topped with cheese, chicken and special sauces.',
  },

  // Drinks (5)
  {
    'name': 'Fresh Lemonade',
    'category': 'Drinks',
    'price': 250,
    'image':
        'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=800&q=80',
    'description': 'Refreshing homemade lemonade served chilled.',
  },
  {
    'name': 'Mango Shake',
    'category': 'Drinks',
    'price': 400,
    'image':
        'https://images.unsplash.com/photo-1546173159-315724a31696?auto=format&fit=crop&w=800&q=80',
    'description': 'Creamy mango shake made with fresh mangoes.',
  },
  {
    'name': 'Chocolate Shake',
    'category': 'Drinks',
    'price': 450,
    'image':
        'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=800&q=80',
    'description': 'Rich and creamy chocolate milkshake.',
  },
  {
    'name': 'Fresh Orange Juice',
    'category': 'Drinks',
    'price': 300,
    'image':
        'https://images.unsplash.com/photo-1600271886742-f049cd451bba?auto=format&fit=crop&w=800&q=80',
    'description': 'Freshly squeezed orange juice served chilled.',
  },
  {
    'name': 'Mint Margarita',
    'category': 'Drinks',
    'price': 350,
    'image':
        'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=800&q=80',
    'description': 'Cool and refreshing mint drink with lemon.',
  },

  // Desserts (5)
  {
    'name': 'Chocolate Cake',
    'category': 'Desserts',
    'price': 400,
    'image':
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=800&q=80',
    'description': 'Rich chocolate cake with creamy chocolate frosting.',
  },
  {
    'name': 'Chocolate Brownie',
    'category': 'Desserts',
    'price': 350,
    'image':
        'https://images.unsplash.com/photo-1564355808539-22fda35bed7e?auto=format&fit=crop&w=800&q=80',
    'description': 'Warm fudgy chocolate brownie.',
  },
  {
    'name': 'Cheesecake',
    'category': 'Desserts',
    'price': 500,
    'image':
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?auto=format&fit=crop&w=800&q=80',
    'description': 'Creamy cheesecake with a delicious biscuit base.',
  },
  {
    'name': 'Ice Cream Sundae',
    'category': 'Desserts',
    'price': 450,
    'image':
        'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=800&q=80',
    'description': 'Creamy ice cream topped with chocolate and nuts.',
  },
  {
    'name': 'Chocolate Lava Cake',
    'category': 'Desserts',
    'price': 550,
    'image':
        'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=800&q=80',
    'description': 'Warm chocolate cake with a rich molten chocolate center.',
  },
];
