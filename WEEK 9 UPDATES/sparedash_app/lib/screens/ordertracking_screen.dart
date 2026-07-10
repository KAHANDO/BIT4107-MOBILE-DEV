// OrderTrackingActivity.kt
// Wires up the order tracking screen — bind your API model to this helper.

package com.sparedash.app.ui.tracking

import android.graphics.Color
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.sparedash.app.R
import com.sparedash.app.databinding.ActivityOrderTrackingBinding
import com.sparedash.app.databinding.ItemTrackingStepBinding

class OrderTrackingActivity : AppCompatActivity() {

  private lateinit var binding: ActivityOrderTrackingBinding

  enum class StepState { DONE, ACTIVE, PENDING }

  override fun onCreate(savedInstanceState: Bundle?) {
  super.onCreate(savedInstanceState)
  binding = ActivityOrderTrackingBinding.inflate(layoutInflater)
  setContentView(binding.root)

  setSupportActionBar(binding.toolbar)
  supportActionBar?.setDisplayHomeAsUpEnabled(true)

  // ── Populate order summary ──────────────────────────────────────────
  binding.tvOrderNumber.text   = "#SD-20482"
  binding.tvItemName.text      = "Toyota Alternator Belt × 2"
  binding.tvItemNameSecondary.text = "Brake Pad Set – 4pcs"
  binding.tvStatusBadge.text   = "In Transit"
  binding.tvOrderDate.text     = "Jun 27, 2026"
  binding.tvEstDelivery.text   = "Jun 28, 2026"
  binding.tvOrderTotal.text    = "KSh 4,850"

  // ── Rider info ──────────────────────────────────────────────────────
  binding.tvRiderName.text     = "James M."
  binding.tvRiderDistance.text = "3.2 km away · ~18 min"

  // ── Timeline steps ─────────────────────────────────────────────────
  // Replace StepState values with values driven by your order API response.
  configureStep(
  step      = ItemTrackingStepBinding.bind(binding.stepOrderPlaced.root),
  label     = "Order Placed",
  timestamp = "Jun 27 · 09:14 AM",
  state     = StepState.DONE,
  showLine  = true
  )
  configureStep(
  step      = ItemTrackingStepBinding.bind(binding.stepPacked.root),
  label     = "Parts Verified & Packed",
  timestamp = "Jun 27 · 11:32 AM",
  state     = StepState.DONE,
  showLine  = true
  )
  configureStep(
  step      = ItemTrackingStepBinding.bind(binding.stepOutForDelivery.root),
  label     = "Out for Delivery",
  timestamp = "En route · Rider: James M.",
  state     = StepState.ACTIVE,
  showLine  = true
  )
  configureStep(
  step      = ItemTrackingStepBinding.bind(binding.stepDelivered.root),
  label     = "Delivered",
  timestamp = "Expected Jun 28 · 10:00 AM",
  state     = StepState.PENDING,
  showLine  = false   // last step — hide connector line
  )

  // ── CTAs ────────────────────────────────────────────────────────────
  binding.btnContactRider.setOnClickListener     { callRider() }
  binding.btnContactRiderFull.setOnClickListener { callRider() }
  }

  /**
   * Applies visual state (DONE / ACTIVE / PENDING) to a single timeline step.
   */
  private fun configureStep(
  step: ItemTrackingStepBinding,
  label: String,
  timestamp: String,
  state: StepState,
  showLine: Boolean
  ) {
  step.tvStepLabel.text = label
  step.tvStepTime.text  = timestamp
  step.viewStepLine.visibility = if (showLine) View.VISIBLE else View.GONE

  when (state) {
  StepState.DONE -> {
  step.ivStepDot.setBackgroundResource(R.drawable.bg_step_dot_done)
  step.ivStepDot.setImageResource(R.drawable.ic_check_small)
  step.tvStepLabel.setTextColor(ContextCompat.getColor(this, R.color.color_primary_dark))
  step.tvStepTime.setTextColor(ContextCompat.getColor(this, R.color.text_muted))
  step.viewStepLine.setBackgroundColor(ContextCompat.getColor(this, R.color.step_line_done))
  }
  StepState.ACTIVE -> {
  step.ivStepDot.setBackgroundResource(R.drawable.bg_step_dot_active)
  step.ivStepDot.setImageResource(R.drawable.ic_arrow_up_small)
  step.tvStepLabel.setTextColor(ContextCompat.getColor(this, R.color.color_accent_orange))
  step.tvStepTime.setTextColor(ContextCompat.getColor(this, R.color.color_accent_orange))
  step.viewStepLine.setBackgroundColor(ContextCompat.getColor(this, R.color.step_line_pending))
  }
  StepState.PENDING -> {
  step.ivStepDot.setBackgroundResource(R.drawable.bg_step_dot_pending)
  step.ivStepDot.setImageResource(R.drawable.ic_circle_outline_small)
  step.tvStepLabel.setTextColor(ContextCompat.getColor(this, R.color.step_pending_icon))
  step.tvStepTime.setTextColor(ContextCompat.getColor(this, R.color.step_pending_icon))
  step.viewStepLine.setBackgroundColor(ContextCompat.getColor(this, R.color.step_line_pending))
  }
  }
  }

  private fun callRider() {
  // TODO: launch phone dialer with rider number
  // val intent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:+254700000000"))
  // startActivity(intent)
  }

  override fun onSupportNavigateUp(): Boolean {
  onBackPressedDispatcher.onBackPressed()
  return true
  }
}