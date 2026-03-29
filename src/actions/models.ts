"use server";

/* eslint-disable @typescript-eslint/no-unused-vars -- imports are for your implementation */
import { revalidatePath } from "next/cache";
import { query } from "@/lib/db";
import { addModelSchema } from "@/lib/validations";
import { getUserId } from "@/lib/auth";
import type { Model } from "@/lib/types";
// ============================================================================
// CHALLENGE TASK 3: Complete the addModel server action
// ============================================================================
//
// This action is called when a user submits the "Add model" form.
//
// Steps:
//   1. Get the current user's ID — return an error if not authenticated
//   2. Extract the fields from formData and validate with addModelSchema
//      (see lib/validations.ts for the schema definition)
//   3. If validation fails, return { error: "<descriptive message>" }
//   4. INSERT the new model into the database
//   5. If the database insert fails, return { error: "<descriptive message>" }
//   6. Revalidate the dashboard path so the new model appears
//   7. Return { success: true }
//
// Check lib/validations.ts for the schema shape.
// Check lib/db.ts for the query helper.
// Check CONVENTIONS.md for the error return format and INSERT patterns.
//
// DO NOT use AI tools. Your screen recording will be reviewed.
// ============================================================================

export async function addModel(
  formData: FormData,
): Promise<{ success: true } | { error: string }> {
  // TODO: Your implementation here

  const userId = await getUserId();

  if (!userId) {
    return { error: "User not authenticated" };
  }
  const parsed = addModelSchema.safeParse({
    name: formData.get("name"),
    model_id: formData.get("model_id"),
    provider_id: formData.get("provider_id"),
    context_window: formData.get("context_window"),
    status: formData.get("status"),
    notes: formData.get("notes"),
  });

  if (!parsed.success) {
    return { error: parsed.error.errors[0].message ?? "Invalid form data" };
  }

  try {
    await query(
      `INSERT INTO models (name, model_id, provider_id, context_window, status, notes, added_by)
        VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [
        parsed.data.name,
        parsed.data.model_id,
        parsed.data.provider_id,
        parsed.data.context_window ?? null,
        parsed.data.status,
        parsed.data.notes ?? null,
        userId,
      ],
    );
  } catch (error) {
    return { error: "Failed to add model" };
  }

  revalidatePath("/dashboard");
  return { success: true };
}
