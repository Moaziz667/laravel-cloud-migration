@extends('layouts.admin_master')

@section('content')
<main>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-7">
                <div class="card shadow-lg border-0 rounded-lg mt-5">
                    <div class="card-header"><h3 class="text-center font-weight-light my-4">Edit Product</h3></div>
                    <div class="card-body">
                        <form method="POST" action="{{ route('products.update', $product) }}">
                            @csrf
                            @method('PUT')
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="product_code">Product Code</label>
                                        <input class="form-control py-4 @error('product_code') is-invalid @enderror" id="product_code" name="product_code" type="text" value="{{ old('product_code', $product->product_code) }}" required />
                                        @error('product_code')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="name">Product Name</label>
                                        <input class="form-control py-4 @error('name') is-invalid @enderror" id="name" name="name" type="text" value="{{ old('name', $product->name) }}" required />
                                        @error('name')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="category">Category</label>
                                        <input class="form-control py-4 @error('category') is-invalid @enderror" id="category" name="category" type="text" value="{{ old('category', $product->category) }}" required />
                                        @error('category')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="stock">Stock</label>
                                        <input class="form-control py-4 @error('stock') is-invalid @enderror" id="stock" name="stock" type="number" min="0" value="{{ old('stock', $product->stock) }}" required />
                                        @error('stock')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="unit_price">Buy Price (per Unit)</label>
                                        <input class="form-control py-4 @error('unit_price') is-invalid @enderror" id="unit_price" name="unit_price" type="number" step="0.01" min="0" value="{{ old('unit_price', $product->unit_price) }}" required />
                                        @error('unit_price')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="sales_unit_price">Sale Price (per Unit)</label>
                                        <input class="form-control py-4 @error('sales_unit_price') is-invalid @enderror" id="sales_unit_price" name="sales_unit_price" type="number" step="0.01" min="0" value="{{ old('sales_unit_price', $product->sales_unit_price) }}" required />
                                        @error('sales_unit_price')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                            </div>

                            <div class="form-group d-flex justify-content-between mt-4 mb-0">
                                <a href="{{ route('all.product') }}" class="btn btn-light">Cancel</a>
                                <button class="btn btn-primary" type="submit">Update Product</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>
@endsection
