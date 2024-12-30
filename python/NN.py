import numpy as np
import math
import struct

def float_to_hex(f):
  """Converts a float to its hexadecimal IEEE 754 representation."""
  packed = struct.pack('!f', f) # Pack the float as big-endian single precision
  return '0x' + packed.hex()   # Convert to hex string with "0x" prefix

def approx_g(x):
  """
  Implements the piecewise activation function approximation.
  Handles potential division-by-zero at x = -1.

  Args:
    x: The input value.

  Returns:
    The output of the approx_g function.
  """
  if x < 0:
    if x == -1:
        return 0 # Handle the division-by-zero case, which in our simulation is equal to 0
    return 1 - 0.5 * (1 + ((-x) / (1 - x)))
  else:
    return 0.5 * (1 + (x / (1 + x)))

def xor_neural_network(A, B, w11, w12, w21, w22, b1, b2, w31, w32, b3):
  """
  Simulates a simple XOR neural network using approx_g activation.

  Args:
      A, B: Inputs (0 or 1).
      w11, w12, w21, w22: Weights from input to hidden layer.
      b1, b2: Biases for the hidden layer.
      w31, w32: Weights from hidden to output layer.
      b3: Bias for the output layer.

  Returns:
      The final XOR output (0 or 1, after rounding).
  """

  print(f"Input A: {A}, Input B: {B}")

  # Hidden Layer Calculations

  # Layer 1
  h1_pre_sig = A * w11 + B * w12 + b1
  #print(f"h1_pre_sig: {h1_pre_sig}  ({float_to_hex(h1_pre_sig)})")
  h1 = approx_g(h1_pre_sig)
  #print(f"h1: {h1} ({float_to_hex(h1)})")

  # Layer 2
  h2_pre_sig = A * w21 + B * w22 + b2
  #print(f"h2_pre_sig: {h2_pre_sig} ({float_to_hex(h2_pre_sig)})")
  h2 = approx_g(h2_pre_sig)
  #print(f"h2: {h2} ({float_to_hex(h2)})")


  # Output Layer Calculation
  XOR_output_pre_sig = h1 * w31 + h2 * w32 + b3
  #print(f"XOR_output_pre_sig: {XOR_output_pre_sig} ({float_to_hex(XOR_output_pre_sig)})")
  XOR_output = approx_g(XOR_output_pre_sig)
  print(f"XOR_output: {XOR_output} ({float_to_hex(XOR_output)})")

  # Return the rounded output
  return round(XOR_output)

if __name__ == '__main__':
  # Example Usage (with some reasonable weights and biases)
    # Example Usage (with some reasonable weights and biases)
    #weights for Layer 1 to Layer 2
  w11 = 4.0 
  w12 = 4.0
  w21 = -4.0
  w22 = -4.0

    #biases for Layer 1 to Layer 2
  b1 = -2.0
  b2 = 6.0
    
    #weights for Layer 2 to Layer 3
  w31 = 4.0
  w32 = 4.0

    #biases for Layer 2 to Layer 3
  b3 = -6.0

  print("---------------------------")
  output = xor_neural_network(0, 0, w11, w12, w21, w22, b1, b2, w31, w32, b3)
  print(f"Final XOR Output: {output}\n")

  print("---------------------------")
  output = xor_neural_network(0, 1, w11, w12, w21, w22, b1, b2, w31, w32, b3)
  print(f"Final XOR Output: {output}\n")

  print("---------------------------")
  output = xor_neural_network(1, 0, w11, w12, w21, w22, b1, b2, w31, w32, b3)
  print(f"Final XOR Output: {output}\n")

  print("---------------------------")
  output = xor_neural_network(1, 1, w11, w12, w21, w22, b1, b2, w31, w32, b3)
  print(f"Final XOR Output: {output}\n")
