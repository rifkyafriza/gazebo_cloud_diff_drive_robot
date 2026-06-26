#!/usr/bin/env python3
import rclpy
from rclpy.node import Node
from sensor_msgs.msg import Image
from std_msgs.msg import Float32
import time

class FpsPublisher(Node):
    def __init__(self):
        super().__init__('fps_publisher')
        self.subscription = self.create_subscription(
            Image,
            '/camera/image_raw',
            self.image_callback,
            1)
        self.publisher = self.create_publisher(Float32, '/camera/fps', 10)
        self.frame_count = 0
        self.start_time = time.time()
        self.timer = self.create_timer(1.0, self.timer_callback)

    def image_callback(self, msg):
        self.frame_count += 1

    def timer_callback(self):
        current_time = time.time()
        elapsed = current_time - self.start_time
        if elapsed > 0:
            fps = self.frame_count / elapsed
            msg = Float32()
            msg.data = float(fps)
            self.publisher.publish(msg)
        self.frame_count = 0
        self.start_time = current_time

def main(args=None):
    rclpy.init(args=args)
    node = FpsPublisher()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
