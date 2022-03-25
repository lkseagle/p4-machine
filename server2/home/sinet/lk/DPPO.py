"""
A simple version of OpenAI's Proximal Policy Optimization (PPO). [https://arxiv.org/abs/1707.06347]

Distributing workers in parallel to collect data, then stop worker's roll-out and train PPO on collected data.
Restart workers once PPO is updated.

The global PPO updating rule is adopted from DeepMind's paper (DPPO):
Emergence of Locomotion Behaviours in Rich Environments (Google Deepmind): [https://arxiv.org/abs/1707.02286]

View more on my tutorial website: https://morvanzhou.github.io/tutorials

Dependencies:
tensorflow r1.3
gym 0.9.2
"""
import os
import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt
import gym, threading, queue
from tensorflow.python.training import checkpoint_management

EP_MAX = 100
EP_LEN = 200
N_WORKER = 4                # parallel workers
GAMMA = 0.9                 # reward discount factor
A_LR = 0.0001               # learning rate for actor
C_LR = 0.0002               # learning rate for critic
MIN_BATCH_SIZE = 64         # minimum batch size for updating PPO
UPDATE_STEP = 100            # loop update operation n-steps
EPSILON = 0.2               # for clipping surrogate objective
GAME = 'Pendulum-v0'
S_DIM, A_DIM = 32, 3         # state and action dimension


class PPO(object):
    def __init__(self):

        self.tfs = tf.compat.v1.placeholder(tf.float32, [None, S_DIM], name='state')
        self.tfdc_r = tf.compat.v1.placeholder(tf.float32, [None, 1], name='discounted_r')
        # ##########################critic
        with tf.compat.v1.variable_scope('advatege_l1',reuse=tf.AUTO_REUSE):
            l1 = tf.layers.dense(self.tfs, 100, tf.nn.relu)
        with tf.compat.v1.variable_scope('advatege_v',reuse=tf.AUTO_REUSE):
            self.v = tf.layers.dense(l1, 1)
            self.advantage = self.tfdc_r - self.v
        with tf.compat.v1.variable_scope('closs',reuse=tf.AUTO_REUSE):
            self.closs = tf.reduce_mean(tf.square(self.advantage))
        with tf.compat.v1.variable_scope('ctrain_op',reuse=tf.AUTO_REUSE):
            self.ctrain_op = tf.train.AdamOptimizer(C_LR).minimize(self.closs)

        # ############################actor
        pi, pi_params = self._build_anet('pi', trainable=True)
        oldpi, oldpi_params = self._build_anet('oldpi', trainable=False)
        self.sample_op = tf.squeeze(pi.sample(1), axis=0)  # operation of choosing action
        self.update_oldpi_op = [oldp.assign(p) for p, oldp in zip(pi_params, oldpi_params)]

        self.tfa = tf.compat.v1.placeholder(tf.float32, [None, A_DIM], name='action')
        self.tfadv = tf.compat.v1.placeholder(tf.float32, [None, 1], name='advantage')
        # ratio = tf.exp(pi.log_prob(self.tfa) - oldpi.log_prob(self.tfa))
        ratio = pi.prob(self.tfa) / (oldpi.prob(self.tfa) + 1e-5)
        surr = ratio * self.tfadv                       # surrogate loss
        with tf.compat.v1.variable_scope('aloss',reuse=tf.AUTO_REUSE):
            self.aloss = -tf.reduce_mean(tf.minimum(        # clipped surrogate objective
                surr,
                tf.clip_by_value(ratio, 1. - EPSILON, 1. + EPSILON) * self.tfadv))
        with tf.compat.v1.variable_scope('atrain_op',reuse=tf.AUTO_REUSE):
            self.atrain_op = tf.train.AdamOptimizer(A_LR).minimize(self.aloss)

        self.sess = tf.compat.v1.Session()
        self.sess.run(tf.compat.v1.global_variables_initializer())
        self.saver = tf.compat.v1.train.Saver(tf.compat.v1.global_variables())

    def update(self,data):
        #UPDATE_EVENT.wait()                     # wait until get batch of data
        self.sess.run(self.update_oldpi_op)     # copy pi to old pi
        #data = [QUEUE.get() for _ in range(QUEUE.qsize())]      # collect data from all workers
        #data=QUEUE.get()
        data = np.vstack(data)
        s, a, r = data[:, :S_DIM], data[:, S_DIM: S_DIM + A_DIM], data[:, -1:]
        adv = self.sess.run(self.advantage, {self.tfs: s, self.tfdc_r: r})
        # update actor and critic in a update loop
        [self.sess.run(self.atrain_op, {self.tfs: s, self.tfa: a, self.tfadv: adv}) for _ in range(UPDATE_STEP)]
        [self.sess.run(self.ctrain_op, {self.tfs: s, self.tfdc_r: r}) for _ in range(UPDATE_STEP)]
        #UPDATE_EVENT.clear()        # updating finished
        #GLOBAL_UPDATE_COUNTER = 0   # reset counter
        #ROLLING_EVENT.set()         # set roll-out available

    def _build_anet(self, name, trainable):
       with tf.compat.v1.variable_scope(name,reuse=tf.AUTO_REUSE):
            l1 = tf.layers.dense(self.tfs, 200, tf.nn.relu, trainable=trainable)
            mu = 2 * tf.layers.dense(l1, A_DIM, tf.nn.relu, trainable=trainable)
            sigma = tf.layers.dense(l1, A_DIM, tf.nn.softplus, trainable=trainable)
            norm_dist = tf.distributions.Normal(loc=mu, scale=sigma)
       params = tf.get_collection(tf.GraphKeys.GLOBAL_VARIABLES, scope=name)
       return norm_dist, params

    def choose_action(self, s):
        s = s[np.newaxis, :]
        a = self.sess.run(self.sample_op, {self.tfs: s})[0]
        return np.clip(a, 10, 90)

    def get_v(self, s):
        if s.ndim < 2: s = s[np.newaxis, :]
        return self.sess.run(self.v, {self.tfs: s})[0, 0]

    def save(self, ckpt_file='/home/sinet/lk/ckpt/dqn.ckpt'):
        if not checkpoint_management.checkpoint_exists(os.path.dirname(ckpt_file)):
            os.makedirs(os.path.dirname(ckpt_file))
        self.saver.save(self.sess, ckpt_file)

    def load(self, ckpt_dir='/home/sinet/lk/ckpt'):
        ckpt = tf.train.get_checkpoint_state(ckpt_dir)
        if ckpt:
            ckpt_name = os.path.basename(ckpt.model_checkpoint_path)
            self.saver.restore(self.sess, os.path.join(ckpt_dir, ckpt_name))
            #print '[SUCCESS] Checkpoint loaded.'
        else:
            print ('[WARNING] No checkpoint found.')


mark=1
def reshapes(shapes):  
    drop=0
    queue=0
    global mark ##mark
    mark=1
    kj=0
    for k in range(32):
         if(mark==1):
            shapes[k]=shapes[k]/10000
            mark=2
            kj=kj+1
         elif(mark==2):
            shapes[k]=shapes[k]/100
            mark=3
         elif(mark==3):
            drop=drop+shapes[k]
            shapes[k]=shapes[k]/10
            mark=4
         elif(mark==4):
            queue=queue+shapes[k]
            shapes[k]=shapes[k]/100
            mark=1
    dropandqueue=drop*10+queue*25
    return shapes,dropandqueue

if __name__ == '__main__':
    GLOBAL_PPO = PPO()
    GLOBAL_PPO.load()
    r1=np.loadtxt("/home/sinet/lk/message/random.txt")# 37 action-3 + throughput + (delay,bw,drop,queue)*4  + throughput + (delay,bw,drop,queue)*4
    m,n=r1.shape
    for t in range(20):
        s=np.hstack((r1[t][4:20],r1[t][21:37])) #(delay,bw,drop,queue)*8
        restate1,dropque1=reshapes(s)  #####lk check weight for ones
        action=GLOBAL_PPO.choose_action(restate1)
        print(action)
    datas=r1.copy()
     #=S.reshape((7,84),order='A')## acion-1,feature1-3 RTT,Throughput,drop,feature2-3
     # print(r1)
    N=r1.shape[0]
    print(N)
    QUEUE = queue.Queue()
    buffer_s, buffer_a, buffer_r = [], [], []
    GLOBAL_UPDATE_COUNTER=0
    for i in range(20,N-2):#N-2
         s=np.hstack((r1[i][4:20],r1[i][21:37]))
         restate1,dropque1=reshapes(s)
         restate2,dropque2=reshapes(np.hstack((r1[i+1][4:20],r1[i+1][21:37])))
     #reward=r1[i+1][4]+r1[i+1][26]-dropque2 ####修改reward：throughput+delay+drop，queue-length
         reward = (r1[i+1][3]+r1[i+1][20]) if dropque2<0 else r1[i+1][3]+r1[i+1][20]-dropque2
         buffer_s.append(restate1)
         buffer_a.append(datas[i][0:3])
         buffer_r.append(reward)
         GLOBAL_UPDATE_COUNTER += 1
    print('storing.....')

    v_s_ = GLOBAL_PPO.get_v(restate2)
    discounted_r = []                           # compute discounted reward
    for r in buffer_r[::-1]:
        v_s_ = r + GAMMA * v_s_
        discounted_r.append(v_s_)
    discounted_r.reverse()

    bs, ba, br = np.vstack(buffer_s), np.vstack(buffer_a), np.array(discounted_r)[:, np.newaxis]
    buffer_s, buffer_a, buffer_r = [], [], []
    QUEUE.put(np.hstack((bs, ba, br)))
    data=QUEUE.get()
    print('alldatas: {}'.format(data))
    for j in range(100):
        print('learning.....')
        GLOBAL_PPO.update(data)
    GLOBAL_PPO.save()
    print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@')
    GLOBAL_PPO.load()
    for t in range(20):
        s=np.hstack((r1[t][4:20],r1[t][21:37]))
        restate1,dropque1=reshapes(s)
        action=GLOBAL_PPO.choose_action(restate1)
        print(action)