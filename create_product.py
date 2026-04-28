from flask import request, jsonify
from sqlalchemy.exc import IntegrityError

@app.route('/api/products', methods=['POST'])
def create_product():
    data = request.json

    # check all required fields are present before using them
    required_fields = ['name', 'sku', 'price', 'warehouse_id']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'Missing field: {field}'}), 400

    # reject negative price
    if data['price'] < 0:
        return jsonify({'error': 'Price cannot be negative'}), 400

    # use .get() so missing initial_quantity defaults to 0
    initial_quantity = data.get('initial_quantity', 0)
    if initial_quantity < 0:
        return jsonify({'error': 'Quantity cannot be negative'}), 400

    try:
        # check if SKU already exists
        if Product.query.filter_by(sku=data['sku']).first():
            return jsonify({'error': 'A product with this SKU already exists'}), 409

        product = Product(
            name=data['name'],
            sku=data['sku'],
            price=data['price'],
            warehouse_id=data['warehouse_id']
        )
        db.session.add(product)

        inventory = Inventory(
            product_id=product.id,
            warehouse_id=data['warehouse_id'],
            quantity=initial_quantity
        )
        db.session.add(inventory)

        # single commit so both save together or both fail
        db.session.commit()

        # return 201 for resource creation
        return jsonify({'message': 'Product created', 'product_id': product.id}), 201

    except IntegrityError:
        db.session.rollback()
        return jsonify({'error': 'Database error, possibly duplicate SKU'}), 409

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Something went wrong on the server'}), 500