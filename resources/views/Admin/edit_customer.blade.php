@extends('layouts.admin_master')

@section('content')

<main>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-7">
                <div class="card shadow-lg border-0 rounded-lg mt-5">
                    <div class="card-header"><h3 class="text-center font-weight-light my-4">Edit Customer</h3></div>
                    <div class="card-body">
                        <form method="POST" action="{{ route('customers.update', $customer) }}">
                            @csrf
                            @method('PUT')
                            <div class="form-row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="name">Full Name</label>
                                        <input class="form-control py-4 @error('name') is-invalid @enderror" id="name" name="name" type="text" value="{{ old('name', $customer->name) }}" required />
                                        @error('name')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="email">Email</label>
                                        <input class="form-control py-4 @error('email') is-invalid @enderror" id="email" name="email" type="email" value="{{ old('email', $customer->email) }}" required />
                                        @error('email')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="company">Company</label>
                                        <input class="form-control py-4 @error('company') is-invalid @enderror" id="company" name="company" type="text" value="{{ old('company', $customer->company) }}" />
                                        @error('company')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="small mb-1" for="phone">Phone</label>
                                        <input class="form-control py-4 @error('phone') is-invalid @enderror" id="phone" name="phone" type="text" value="{{ old('phone', $customer->phone) }}" />
                                        @error('phone')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label class="small mb-1" for="address">Address</label>
                                        <textarea class="form-control @error('address') is-invalid @enderror" id="address" name="address" rows="3">{{ old('address', $customer->address) }}</textarea>
                                        @error('address')
                                            <div class="invalid-feedback">{{ $message }}</div>
                                        @enderror
                                    </div>
                                </div>
                            </div>
                            <div class="form-group d-flex justify-content-between mt-4 mb-0">
                                <a href="{{ route('all.customers') }}" class="btn btn-light">Cancel</a>
                                <button class="btn btn-primary" type="submit">Update Customer</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

@endsection