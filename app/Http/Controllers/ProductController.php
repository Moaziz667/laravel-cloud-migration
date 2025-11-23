<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'code' => ['required', 'string', 'max:50', 'unique:products,product_code'],
            'name' => ['required', 'string', 'max:255'],
            'category' => ['required', 'string', 'max:255'],
            'stock' => ['required', 'integer', 'min:0'],
            'unit_price' => ['required', 'numeric', 'min:0'],
            'sale_price' => ['required', 'numeric', 'min:0'],
        ]);

        Product::create([
            'product_code' => $validated['code'],
            'name' => $validated['name'],
            'category' => $validated['category'],
            'stock' => $validated['stock'],
            'unit_price' => $validated['unit_price'],
            'sales_unit_price' => $validated['sale_price'],
        ]);

        return redirect()->route('all.product')->with('status', 'Product created successfully.');
    }

    public function allProduct()
    {
        $products = Product::orderBy('created_at', 'desc')->get();

        return view('Admin.all_product', compact('products'));
    }

    public function availableProducts()
    {
        $products = Product::where('stock', '>', 0)->orderBy('name')->get();

        return view('Admin.available_products', compact('products'));
    }

    public function formData($id)
    {
        $product = Product::findOrFail($id);

        return view('Admin.add_order', compact('product'));
    }

    public function purchaseData($id)
    {
        $product = Product::findOrFail($id);

        return view('Admin.purchase_products', compact('product'));
    }

    public function storePurchase(Request $request)
    {
        $validated = $request->validate([
            'product_id' => ['required', 'exists:products,id'],
            'purchase' => ['required', 'integer', 'min:1'],
        ]);

        $product = Product::findOrFail($validated['product_id']);
        $product->increment('stock', $validated['purchase']);

        return redirect()->route('all.product')->with('status', 'Stock updated successfully.');
    }

    public function edit(Product $product)
    {
        return view('Admin.edit_product', compact('product'));
    }

    public function update(Request $request, Product $product)
    {
        $validated = $request->validate([
            'product_code' => ['required', 'string', 'max:50', 'unique:products,product_code,' . $product->id],
            'name' => ['required', 'string', 'max:255'],
            'category' => ['required', 'string', 'max:255'],
            'stock' => ['required', 'integer', 'min:0'],
            'unit_price' => ['required', 'numeric', 'min:0'],
            'sales_unit_price' => ['required', 'numeric', 'min:0'],
        ]);

        $product->update($validated);

        return redirect()->route('all.product')->with('status', 'Product updated successfully.');
    }

    public function destroy(Product $product)
    {
        $product->delete();

        return redirect()->route('all.product')->with('status', 'Product deleted successfully.');
    }

}
