import React, { type ReactNode } from 'react';
import { motion, AnimatePresence, type HTMLMotionProps } from 'framer-motion';
import {
  fadeIn,
  slideUp,
  slideDown,
  scaleIn,
  popIn,
  staggerContainer,
  staggerItem,
  cardHover,
  pageTransition,
} from '../../lib/animations';

// Animated container with fade
export const FadeIn: React.FC<{ children: ReactNode; delay?: number; className?: string }> = ({
  children,
  delay = 0,
  className
}) => (
  <motion.div
    initial="hidden"
    animate="visible"
    exit="exit"
    variants={fadeIn}
    transition={{ delay }}
    className={className}
  >
    {children}
  </motion.div>
);

// Animated slide up
export const SlideUp: React.FC<{ children: ReactNode; delay?: number; className?: string }> = ({
  children,
  delay = 0,
  className
}) => (
  <motion.div
    initial="hidden"
    animate="visible"
    exit="exit"
    variants={slideUp}
    transition={{ delay }}
    className={className}
  >
    {children}
  </motion.div>
);

// Animated slide down
export const SlideDown: React.FC<{ children: ReactNode; delay?: number; className?: string }> = ({
  children,
  delay = 0,
  className
}) => (
  <motion.div
    initial="hidden"
    animate="visible"
    exit="exit"
    variants={slideDown}
    transition={{ delay }}
    className={className}
  >
    {children}
  </motion.div>
);

// Animated scale in
export const ScaleIn: React.FC<{ children: ReactNode; delay?: number; className?: string }> = ({
  children,
  delay = 0,
  className
}) => (
  <motion.div
    initial="hidden"
    animate="visible"
    exit="exit"
    variants={scaleIn}
    transition={{ delay }}
    className={className}
  >
    {children}
  </motion.div>
);

// Animated pop in (spring)
export const PopIn: React.FC<{ children: ReactNode; delay?: number; className?: string }> = ({
  children,
  delay = 0,
  className
}) => (
  <motion.div
    initial="hidden"
    animate="visible"
    exit="exit"
    variants={popIn}
    transition={{ delay }}
    className={className}
  >
    {children}
  </motion.div>
);

// Stagger container for lists
export const StaggerList: React.FC<{ children: ReactNode; className?: string }> = ({
  children,
  className
}) => (
  <motion.div
    initial="hidden"
    animate="visible"
    variants={staggerContainer}
    className={className}
  >
    {children}
  </motion.div>
);

// Stagger item
export const StaggerItem: React.FC<{ children: ReactNode; className?: string }> = ({
  children,
  className
}) => (
  <motion.div variants={staggerItem} className={className}>
    {children}
  </motion.div>
);

// Animated card with hover effect
export const AnimatedCard: React.FC<{
  children: ReactNode;
  className?: string;
  onClick?: () => void;
}> = ({ children, className, onClick }) => (
  <motion.div
    initial="rest"
    whileHover="hover"
    whileTap="tap"
    variants={cardHover}
    onClick={onClick}
    className={className}
    style={{ cursor: onClick ? 'pointer' : 'default' }}
  >
    {children}
  </motion.div>
);

// Animated button
export const AnimatedButton: React.FC<
  HTMLMotionProps<'button'> & { children: ReactNode }
> = ({ children, className, ...props }) => (
  <motion.button
    whileHover={{ scale: 1.02 }}
    whileTap={{ scale: 0.98 }}
    className={className}
    {...props}
  >
    {children}
  </motion.button>
);

// Page wrapper with transition
export const PageTransition: React.FC<{ children: ReactNode; className?: string }> = ({
  children,
  className
}) => (
  <motion.div
    initial="initial"
    animate="animate"
    exit="exit"
    variants={pageTransition}
    className={className}
  >
    {children}
  </motion.div>
);

// Animated counter
export const AnimatedCounter: React.FC<{
  value: number;
  duration?: number;
  className?: string;
}> = ({ value, duration = 1, className }) => {
  return (
    <motion.span
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      key={value}
      className={className}
    >
      <motion.span
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration }}
      >
        {value.toLocaleString('de-DE')}
      </motion.span>
    </motion.span>
  );
};

// Presence wrapper for conditional rendering
export const AnimatedPresenceWrapper: React.FC<{
  children: ReactNode;
  show: boolean;
  mode?: 'wait' | 'sync' | 'popLayout';
}> = ({ children, show, mode = 'wait' }) => (
  <AnimatePresence mode={mode}>
    {show && children}
  </AnimatePresence>
);

// Shimmer effect
export const Shimmer: React.FC<{ className?: string }> = ({ className }) => (
  <motion.div
    className={`bg-gradient-to-r from-gray-700 via-gray-600 to-gray-700 ${className}`}
    animate={{
      backgroundPosition: ['200% 0', '-200% 0'],
    }}
    transition={{
      duration: 1.5,
      repeat: Infinity,
      ease: 'linear',
    }}
    style={{ backgroundSize: '200% 100%' }}
  />
);

// Loading spinner with animation
export const AnimatedSpinner: React.FC<{ size?: number; className?: string }> = ({
  size = 24,
  className
}) => (
  <motion.div
    className={className}
    animate={{ rotate: 360 }}
    transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
    style={{ width: size, height: size }}
  >
    <svg viewBox="0 0 24 24" fill="none" className="w-full h-full">
      <circle
        cx="12"
        cy="12"
        r="10"
        stroke="currentColor"
        strokeWidth="3"
        strokeLinecap="round"
        className="opacity-25"
      />
      <path
        d="M12 2a10 10 0 0 1 10 10"
        stroke="currentColor"
        strokeWidth="3"
        strokeLinecap="round"
      />
    </svg>
  </motion.div>
);

export default {
  FadeIn,
  SlideUp,
  SlideDown,
  ScaleIn,
  PopIn,
  StaggerList,
  StaggerItem,
  AnimatedCard,
  AnimatedButton,
  PageTransition,
  AnimatedCounter,
  AnimatedPresenceWrapper,
  Shimmer,
  AnimatedSpinner,
};
