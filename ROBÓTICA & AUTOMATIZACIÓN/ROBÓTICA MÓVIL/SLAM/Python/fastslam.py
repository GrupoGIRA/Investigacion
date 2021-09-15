"""
FastSLAM algorithm implementation
Authors:
--  Robert Alexander Limas S
--  Wilson Javier Perez H
TOP LEVEL
Year: 2021
"""
from read_data import read_world, read_sensor_data
from misc_tools import *
import numpy as np
import math
import copy

#plot preferences, interactive plotting mode
plt.axis([-1, 12, 0, 10])
plt.ion()
plt.show()

def initialize_particles(num_particles, num_landmarks):
    #initialize particle at pose [0,0,0] with an empty map

    particles = []

    for i in range(num_particles):
        particle = dict()

        #initialize pose: at the beginning, robot is certain it is at [0,0,0]
        particle['x'] = 0
        particle['y'] = 0
        particle['theta'] = 0

        #initial weight
        particle['weight'] = 1.0 / num_particles
        
        #particle history aka all visited poses
        particle['history'] = []

        #initialize landmarks of the particle
        landmarks = dict()

        for i in range(num_landmarks):
            landmark = dict()

            #initialize the landmark mean and covariance 
            landmark['mu'] = [0,0]
            landmark['sigma'] = np.zeros([2,2])
            landmark['observed'] = False

            landmarks[i+1] = landmark

        #add landmarks to particle
        particle['landmarks'] = landmarks

        #add particle to set
        particles.append(particle)

    return particles


def sample_motion_model(odometry, particles):
    # Updates the particle positions, based on old positions, the odometry
    # measurements and the motion noise 

    delta_rot1 = odometry['r1']
    delta_trans = odometry['t']
    delta_rot2 = odometry['r2']

    # the motion noise parameters: [alpha1, alpha2, alpha3, alpha4]
    noise = [0.1, 0.1, 0.05, 0.05]

    # standard deviations of motion noise
    sigma_delta_rot1 = noise[0] * abs(delta_rot1) + noise[1] * delta_trans
    
    sigma_delta_trans = noise[2] * delta_trans + \
                        noise[3] * (abs(delta_rot1) + abs(delta_rot2))
                        
    sigma_delta_rot2 = noise[0] * abs(delta_rot2) + noise[1] * delta_trans
    
    # "move" each particle according to the odometry measurements plus sampled noise
    for particle in particles:
    
        #sample noisy motions
        noisy_delta_rot1 = delta_rot1 + np.random.normal(0, sigma_delta_rot1)
        noisy_delta_trans = delta_trans + np.random.normal(0, sigma_delta_trans)
        noisy_delta_rot2 = delta_rot2 + np.random.normal(0, sigma_delta_rot2)
        
        #remember last position to draw path of particle
        particle['history'].append([particle['x'], particle['y']])
        
        # calculate new particle pose
        particle['x'] = particle['x'] + \
                        noisy_delta_trans * np.cos(particle['theta'] + noisy_delta_rot1)
                        
        particle['y'] = particle['y'] + \
                        noisy_delta_trans * np.sin(particle['theta'] + noisy_delta_rot1)
                        
        particle['theta'] = particle['theta'] + \
                            noisy_delta_rot1 + noisy_delta_rot2
        
    return


def measurement_model(particle, landmark):
    #Compute the expected measurement for a landmark
    #and the Jacobian with respect to the landmark.

    px = particle['x']
    py = particle['y']
    ptheta = particle['theta']

    lx = landmark['mu'][0]
    ly = landmark['mu'][1]

    #calculate expected range measurement
    meas_range_exp = np.sqrt( (lx - px)**2 + (ly - py)**2 )
    meas_bearing_exp = math.atan2(ly - py, lx - px) - ptheta

    h = np.array([meas_range_exp, meas_bearing_exp])

    # Compute the Jacobian H of the measurement function h 
    #wrt the landmark location
    
    H = np.zeros((2,2))
    H[0,0] = (lx - px) / h[0]
    H[0,1] = (ly - py) / h[0]
    H[1,0] = (py - ly) / (h[0]**2)
    H[1,1] = (lx - px) / (h[0]**2)

    return h, H


def eval_sensor_model(sensor_data, particles):
    #Correct landmark poses with a measurement and
    #calculate particle weight

    #sensor noise
    Q_t = np.array([[0.1, 0],\
                    [0, 0.1]])

    #measured landmark ids and ranges
    ids = sensor_data['id']
    ranges = sensor_data['range']
    bearings = sensor_data['bearing']

    #update landmarks and calculate weight for each particle
    for particle in particles:

        landmarks = particle['landmarks']

        px = particle['x']
        py = particle['y']
        ptheta = particle['theta'] 

        #loop over observed landmarks 
        for i in range(len(ids)):

            #current landmark
            lm_id = ids[i]
            landmark = landmarks[lm_id]
            
            #measured range and bearing to current landmark
            meas_range = ranges[i]
            meas_bearing = bearings[i]

            if not landmark['observed']:
                # landmark is observed for the first time
                
                #initialize landmark position based on the measurement and particle pose
                lx = px + meas_range * np.cos(ptheta + meas_bearing)
                ly = py + meas_range * np.sin(ptheta + meas_bearing)
                landmark['mu'] = [lx, ly]
                
                #get expected measurement and Jacobian wrt. landmark position
                h, H = measurement_model(particle, landmark)
                
                #initialize covariance for this landmark
                H_inv = np.linalg.inv(H)
                landmark['sigma'] = H_inv.dot(Q_t).dot(H_inv.T)
                
                landmark['observed'] = True

            else:
                # landmark was observed before

                #get expected measurement and Jacobian wrt. landmark position
                h, H = measurement_model(particle, landmark)
                
                #Calculate measurement covariance and Kalman gain
                S = landmark['sigma']
                Q = H.dot(S).dot(H.T) + Q_t
                K = S.dot(H.T).dot(np.linalg.inv(Q))
                
                #Compute the difference between the observed and the expected measurement
                delta = np.array([meas_range - h[0], angle_diff(meas_bearing,h[1])])
                
                #update estimated landmark position and covariance
                landmark['mu'] = landmark['mu'] + K.dot(delta)
                landmark['sigma'] = (np.identity(2) - K.dot(H)).dot(S)
                
                # compute the likelihood of this observation
                fact = 1 / np.sqrt(math.pow(2*math.pi,2) * np.linalg.det(Q))
                expo = -0.5 * np.dot(delta.T, np.linalg.inv(Q)).dot(delta)
                weight = fact * np.exp(expo)
                
                # alternatively, evaluate normal density with scipy:
                # weight = scipy.stats.multivariate_normal.pdf(delta, \
                # mean=np.array([0,0]), cov=Q)
                
                # calculate overall weight, account for observing
                # multiple landmarks at one time step
                particle['weight'] = particle['weight'] * weight

    #normalize weights
    normalizer = sum([p['weight'] for p in particles])

    for particle in particles:
        particle['weight'] = particle['weight'] / normalizer
    
    return


def resample_particles(particles):
    # Returns a new set of particles obtained by performing
    # stochastic universal sampling, according to the particle
    # weights.
    
    # distance between pointers
    step = 1.0/len(particles)
    
    # random start of first pointer
    u = np.random.uniform(0,step)
    
    # where we are along the weights
    c = particles[0]['weight']
    
    # index of weight container and corresponding particle
    i = 0
    
    new_particles = []
    
    #loop over all particle weights
    for particle in particles:
    
        #go through the weights until you find the particle
        #to which the pointer points
        while u > c:
        
            i = i + 1
            c = c + particles[i]['weight']
            
        #add that particle
        new_particle = copy.deepcopy(particles[i])
        new_particle['weight'] = 1.0/len(particles)
        new_particles.append(new_particle)
        
        #increase the threshold
        u = u + step
    
    return new_particles


def main():

    print("Reading landmark positions")
    landmarks = read_world("../data/world.dat")

    print("Reading sensor data")
    sensor_readings = read_sensor_data("../data/sensor_data.dat")

    num_particles = 100
    num_landmarks = len(landmarks)

    #create particle set
    particles = initialize_particles(num_particles, num_landmarks)

    #run FastSLAM
    timesteps = int(len(sensor_readings)/2)

    for timestep in range(timesteps):

        #predict particles by sampling from motion model with odometry info
        sample_motion_model(sensor_readings[timestep,'odometry'], particles)

        #evaluate sensor model to update landmarks and calculate particle weights
        eval_sensor_model(sensor_readings[timestep, 'sensor'], particles)

        #plot filter state
        plot_state(particles, landmarks)

        #calculate new set of equally weighted particles
        particles = resample_particles(particles)

    plt.show('hold')

if __name__ == "__main__":
    main()