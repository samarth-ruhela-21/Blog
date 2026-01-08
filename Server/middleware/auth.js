// import jwt from 'jsonwebtoken';

// const auth = (req, res, next)=>{
//     const token = req.headers.authorization;

//     try{
//         jwt.verify(token, process.env.JWT_SECRET)
//         next();
//     }catch(error){
//         res.json({success: false, message: "Invalid token"})
//     }
// }

// export default auth;

import jwt from 'jsonwebtoken';

const auth = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ success: false, message: "No token provided" });
  }

  const token = authHeader.startsWith("Bearer ")
    ? authHeader.split(" ")[1]
    : authHeader;

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // Optional: attach user data to request
    next();
  } catch (error) {
    res.status(401).json({ success: false, message: "Invalid token" });
  }
};

export default auth;
