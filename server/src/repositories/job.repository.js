const { prisma } = require("../lib/prisma");

/**
 * Xây dựng mệnh đề where cho tìm kiếm job công khai (Public Jobs)
 * Áp dụng OCP (Open/Closed Principle) - Dễ dàng mở rộng thêm tiêu chí lọc mà không sửa cấu trúc hàm truy vấn.
 */
function buildPublicJobWhere(filters = {}) {
  const where = {
    status: "open",
  };

  const conditions = [];

  // 1. Tìm kiếm từ khóa q trên title, description, companyName
  if (typeof filters.q === "string" && filters.q.trim().length > 0) {
    const keyword = filters.q.trim();
    conditions.push({
      OR: [
        { title: { contains: keyword, mode: "insensitive" } },
        { description: { contains: keyword, mode: "insensitive" } },
        { companyName: { contains: keyword, mode: "insensitive" } },
      ],
    });
  }

  // 2. Lọc theo kỹ năng (skills) - hasSome, không phân biệt hoa/thường
  // Mở rộng query sang các dạng phổ biến: lowercase, Capitalize, UPPERCASE
  // (PostgreSQL array hasSome phân biệt hoa thường)
  if (Array.isArray(filters.skills) && filters.skills.length > 0) {
    const skillVariants = filters.skills.flatMap((s) => {
      const lower = s.toLowerCase();
      const upper = s.toUpperCase();
      const capitalized = s.charAt(0).toUpperCase() + s.slice(1).toLowerCase();
      return [lower, upper, capitalized, s];
    });
    // Loại trùng
    const uniqueVariants = [...new Set(skillVariants)];
    conditions.push({
      requiredSkills: {
        hasSome: uniqueVariants,
      },
    });
  }

  // 3. Lọc theo cấp bậc (level: intern | fresher | junior | mid | senior | lead)
  if (typeof filters.level === "string" && filters.level.trim().length > 0) {
    conditions.push({
      level: filters.level.trim().toLowerCase(),
    });
  }

  // 4. Lọc theo hình thức làm việc (workMode: onsite | hybrid | remote)
  if (typeof filters.workMode === "string" && filters.workMode.trim().length > 0) {
    conditions.push({
      workMode: filters.workMode.trim().toLowerCase(),
    });
  }

  // 5. Lọc theo địa điểm (location)
  if (typeof filters.location === "string" && filters.location.trim().length > 0) {
    conditions.push({
      location: { contains: filters.location.trim(), mode: "insensitive" },
    });
  }

  if (conditions.length > 0) {
    where.AND = conditions;
  }

  return where;
}

/**
 * Lấy danh sách việc làm công khai kèm phân trang
 */
async function findPublicJobs({ where = {}, skip = 0, take = 10, orderBy = { createdAt: "desc" } } = {}, db = prisma) {
  const [items, totalItems] = await Promise.all([
    db.job.findMany({
      where,
      skip,
      take,
      orderBy,
      include: {
        recruiter: {
          select: {
            id: true,
            fullName: true,
            avatarUrl: true,
            recruiterProfile: {
              select: {
                companyName: true,
                companyLogoUrl: true,
                position: true,
              },
            },
          },
        },
        _count: {
          select: {
            applications: true,
          },
        },
      },
    }),
    db.job.count({ where }),
  ]);

  return { items, totalItems };
}

/**
 * Lấy chi tiết việc làm theo ID
 */
async function findJobById(id, db = prisma) {
  return db.job.findUnique({
    where: { id },
    include: {
      recruiter: {
        select: {
          id: true,
          fullName: true,
          avatarUrl: true,
          recruiterProfile: {
            select: {
              companyName: true,
              companyLogoUrl: true,
              position: true,
            },
          },
        },
      },
      _count: {
        select: {
          applications: true,
        },
      },
    },
  });
}

/**
 * Lấy danh sách việc làm do nhà tuyển dụng cụ thể đăng (kèm lọc status và phân trang)
 */
async function findRecruiterJobs({ recruiterId, status, skip = 0, take = 10, orderBy = { createdAt: "desc" } } = {}, db = prisma) {
  const where = { recruiterId };

  if (typeof status === "string" && status.trim().length > 0) {
    where.status = status.trim().toLowerCase();
  }

  const [items, totalItems] = await Promise.all([
    db.job.findMany({
      where,
      skip,
      take,
      orderBy,
      include: {
        _count: {
          select: {
            applications: true,
          },
        },
      },
    }),
    db.job.count({ where }),
  ]);

  return { items, totalItems };
}

module.exports = {
  buildPublicJobWhere,
  findPublicJobs,
  findJobById,
  findRecruiterJobs,
};
