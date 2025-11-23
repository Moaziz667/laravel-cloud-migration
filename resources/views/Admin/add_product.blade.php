@extends('layouts.admin_master')

@section('content')

<main>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-7">
                <div class="card shadow-lg border-0 rounded-lg mt-5">
                    <div class="card-header"><h3 class="text-center font-weight-light my-4">Add New Product</h3></div>
                    <div class="card-body">
                                            @if($errors->any())
                                                <div class="alert alert-danger">
                                                    <ul class="mb-0">
                                                        @foreach($errors->all() as $error)
                                                            <li>{{ $error }}</li>
                                                        @endforeach
                                                    </ul>
                                                </div>
                                            @endif
                                            <form method="POST" action="{{ url('/insert-product') }}" enctype="multipart/form-data">
                        @csrf
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="inputFirstName">Product Code</label>
                                        <input class="form-control py-4 @error('code') is-invalid @enderror" name="code" type="text" value="{{ old('code') }}" required />
                                        @error('code')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="inputFirstName">Product Name</label>
                                        <input class="form-control py-4 @error('name') is-invalid @enderror" name="name" type="text" value="{{ old('name') }}" required />
                                        @error('name')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="inputLastName">Category</label>
                                        <input class="form-control py-4 @error('category') is-invalid @enderror" name="category" type="text" value="{{ old('category') }}" required />
                                        @error('category')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="inputLastName">Stock</label>
                                        <input class="form-control py-4 @error('stock') is-invalid @enderror" name="stock" type="number" min="0" value="{{ old('stock') }}" required />
                                        @error('stock')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="inputLastName">Buy Price (perUnit)</label>
                                        <input class="form-control py-4 @error('unit_price') is-invalid @enderror" name="unit_price" type="number" step="0.01" min="0" value="{{ old('unit_price') }}" required />
                                        @error('unit_price')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="inputLastName">Sale Price(perUnit)</label>
                                        <input class="form-control py-4 @error('sale_price') is-invalid @enderror" name="sale_price" type="number" step="0.01" min="0" value="{{ old('sale_price') }}" required />
                                        @error('sale_price')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>

                                <!-- <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="inputLastName">Gallery</label>
                                        <input name="photo" type="file" />
                                    </div>
                                </div> -->
                            </div>

                            <div class="form-group mt-4 mb-0"><button class="btn btn-primary btn-block">Submit</button></div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

@endsection