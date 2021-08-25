import numpy as np
gear_ratio = 35


# IDN P-0-0094 (Configured channel peak torque) in Nm
peak_channel_peak_torque =  2.98

# IDN P-0-0505 (Velocity controller output)  per thousand; one-tenth of a per cent (‰)
velocity_controller_output = -9.2


print("The current torque at joint 3 is: ",velocity_controller_output/1000*peak_channel_peak_torque*gear_ratio)


# Torque/force feedback value S-0-0084  per thousand; one-tenth of a per cent (‰)
Torque_feedback = -9.9 


print("The current torque at joint 3 is: ",Torque_feedback/100*peak_channel_peak_torque*gear_ratio)




m_L3 = 1.1138
g = 9.81
L3 = 1.5
analytical_torque = m_L3*g*L3/2
print("The analytical torque at joint 3 is: ",analytical_torque)
