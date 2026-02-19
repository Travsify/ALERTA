<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TrustedContact;
use Illuminate\Http\Request;

/**
 * @group Trusted Contacts
 *
 * APIs for managing emergency trusted contacts.
 */
class ContactController extends Controller
{
    public function index(Request $request)
    {
        $contacts = $request->user()->trustedContacts;

        return response()->json($contacts);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'required|string|max:255',
            'relationship' => 'required|string|max:255',
            'receives_sos' => 'nullable|boolean',
            'receives_location' => 'nullable|boolean',
        ]);

        $contact = $request->user()->trustedContacts()->create($request->all());

        return response()->json([
            'contact' => $contact,
            'message' => 'Contact added successfully',
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $contact = TrustedContact::findOrFail($id);

        // Ensure user owns this contact
        if ($contact->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'phone' => 'sometimes|string|max:255',
            'relationship' => 'sometimes|string|max:255',
            'receives_sos' => 'nullable|boolean',
            'receives_location' => 'nullable|boolean',
        ]);

        $contact->update($request->all());

        return response()->json([
            'contact' => $contact,
            'message' => 'Contact updated successfully',
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $contact = TrustedContact::findOrFail($id);

        // Ensure user owns this contact
        if ($contact->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $contact->delete();

        return response()->json([
            'message' => 'Contact deleted successfully',
        ]);
    }
}
