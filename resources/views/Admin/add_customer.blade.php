@extends('layouts.admin_master')

@section('content')

<main>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-7">
                <div class="card shadow-lg border-0 rounded-lg mt-5">
                    <div class="card-header"><h1 class="text-center font-weight-light my-4"><b>Add New Customer</b></h1></div>
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
                        <form method="POST" action="{{ url('/insert-customer') }}" enctype="multipart/form-data">
                        @csrf
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="inputFirstName">Customer Name</label>
                                        <input class="form-control py-4 @error('name') is-invalid @enderror" name="name" type="text" value="{{ old('name') }}" required />
                                        @error('name')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="inputFirstName">Customer Email</label>
                                        <input class="form-control py-4 @error('email') is-invalid @enderror" name="email" type="email" value="{{ old('email') }}" required />
                                        @error('email')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="inputLastName">Company</label>
                                        <input class="form-control py-4 @error('company') is-invalid @enderror" name="company" type="text" value="{{ old('company') }}" />
                                        @error('company')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="inputLastName">Address</label>
                                        <input class="form-control py-4 @error('address') is-invalid @enderror" name="address" type="text" value="{{ old('address') }}" />
                                        @error('address')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="inputLastName">Phone</label>
                                        <input class="form-control py-4 @error('phone') is-invalid @enderror" name="phone" type="text" value="{{ old('phone') }}" />
                                        @error('phone')
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