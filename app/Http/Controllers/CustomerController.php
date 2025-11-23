<?php

namespace App\Http\Controllers;

use App\Models\Customer;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class CustomerController extends Controller
{
    public function customersData()
    {
        $customers = Customer::orderBy('created_at', 'desc')->get();

        return view('Admin.all_customers', compact('customers'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:customers,email'],
            'company' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:50'],
        ]);

        Customer::create($validated);

        return redirect()->route('all.customers')->with('status', 'Customer created successfully.');
    }

    public function edit(Customer $customer)
    {
        return view('Admin.edit_customer', compact('customer'));
    }

    public function update(Request $request, Customer $customer)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', Rule::unique('customers', 'email')->ignore($customer->id)],
            'company' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:50'],
        ]);

        $customer->update($validated);

        return redirect()->route('all.customers')->with('status', 'Customer updated successfully.');
    }

    public function destroy(Customer $customer)
    {
        $customer->delete();

        return redirect()->route('all.customers')->with('status', 'Customer deleted successfully.');
    }
}