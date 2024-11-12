## COMPUTING Nth ROOT OF FLOATING POINT NUMBER(SINGLE PRECISION) USING CORDIC 
#### Single Precision Floating Point Representation:

![fpn_representation](https://github.com/user-attachments/assets/e4b5715b-d29b-40d3-a0f8-23893379a29d)


#### The formula for a single-precision floating-point number can be expressed as:

$$
B = (-1)^S \times 1.M \times 2^p
$$

where \( p = E - 127 \).

#### To calculate Nth Root:

$$
R^{\frac{1}{N}} = (M \times 2^{E - 127})^{\frac{1}{N}} = M^{\frac{1}{N}} \times 2^{\frac{E - 127}{N}}
$$

where R is the Single Precision Floating Point Number.

$$
R^{\frac{1}{N}} = \exp\left(\frac{\ln(R)}{N}\right)
$$

### ARCHITECTURE

![BLOCK-DIAGRAM](https://github.com/user-attachments/assets/ea194546-a137-4027-90d2-1b62f5c7e27b)


### SIMULATION RESULTS

#### Square Root

![square_root](https://github.com/user-attachments/assets/4345e23c-1f63-4df0-b72f-1c2eec3c92bb)

#### Cube Root

![CUBE_ROOT](https://github.com/user-attachments/assets/7311444b-d5ff-47fe-b4a9-df2cbdf93110)

### POST SYNTHESIS RESULTS



