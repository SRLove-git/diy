import { BadRequestException, NotFoundException } from '@nestjs/common';
import { AuthService } from './auth.service';
import { hashPassword } from './password.util';

function buildService() {
  const redis = {};
  const users = {
    findById: jest.fn(),
    setPasswordHash: jest.fn(),
  };
  const jwt = {};
  const config = {};
  const svc = new AuthService(
    redis as never,
    users as never,
    jwt as never,
    config as never,
  );
  return { svc, users };
}

describe('AuthService.changePassword', () => {
  it('原密码正确时写入新密码（scrypt 哈希）', async () => {
    const m = buildService();
    const current = await hashPassword('old-pass');
    m.users.findById.mockResolvedValue({ id: 7, passwordHash: current });
    m.users.setPasswordHash.mockResolvedValue(undefined);

    const result = await m.svc.changePassword(7, 'old-pass', 'new-pass-123');

    expect(result).toEqual({ sent: true });
    expect(m.users.setPasswordHash).toHaveBeenCalledWith(
      7,
      expect.stringMatching(/^scrypt\$/),
    );
  });

  it('原密码不正确时拒绝修改', async () => {
    const m = buildService();
    m.users.findById.mockResolvedValue({
      id: 7,
      passwordHash: await hashPassword('real-pass'),
    });

    await expect(
      m.svc.changePassword(7, 'wrong-pass', 'new-pass-123'),
    ).rejects.toThrow(BadRequestException);
  });

  it('未设置密码的老账号可直接设置新密码（无需原密码）', async () => {
    const m = buildService();
    m.users.findById.mockResolvedValue({ id: 7, passwordHash: null });

    await m.svc.changePassword(7, undefined, 'new-pass-123');

    expect(m.users.setPasswordHash).toHaveBeenCalledWith(
      7,
      expect.stringMatching(/^scrypt\$/),
    );
  });

  it('用户不存在时返回 404', async () => {
    const m = buildService();
    m.users.findById.mockResolvedValue(null);

    await expect(
      m.svc.changePassword(999, 'old-pass', 'new-pass-123'),
    ).rejects.toThrow(NotFoundException);
  });
});
