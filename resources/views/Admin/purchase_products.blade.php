@extends('layouts.admin_master')

@section('content')

<main>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-7">
                <div class="card shadow-lg border-0 rounded-lg mt-5">
                    <div class="card-header"><h3 class="text-center font-weight-light my-4">Purchase Existing Product</h3></div>
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
                        <form method="POST" action="{{ url('/insert-purchase-products') }}" enctype="multipart/form-data">
                        @csrf
                            <input type="hidden" name="product_id" value="{{ $product->id }}">
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="inputFirstName">Product Code</label>
                                        <input class="form-control py-4" name="code" type="text" value="{{ $product->product_code }}" readonly />
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="inputFirstName">Product Name</label>
                                        <input class="form-control py-4" name="name" type="text" value="{{ $product->name }}" readonly />
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="inputLastName">Category</label>
                                        <input class="form-control py-4" name="category" type="text" value="{{ $product->category }}" readonly />
                                    </div>
                                </div>
                                
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="inputLastName">Products in Stock</label>
                                        <input class="form-control py-4" name="stock" type="text" value="{{ $product->stock }}" readonly />
                                    </div>
                                </div>
                                
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="inputLastName">Add More Product in Stock</label>
                                        <input class="form-control py-4 @error('purchase') is-invalid @enderror" name="purchase" type="number" min="1" required />
                                        @error('purchase')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                
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