import { ChatService } from './chat.service';

describe('ChatService.getMessages', () => {
  function buildService(andWhereCalls: string[]) {
    const fakeQb = {
      leftJoin: jest.fn().mockReturnThis(),
      where: jest.fn().mockReturnThis(),
      andWhere: jest.fn((cond: string) => {
        andWhereCalls.push(cond);
        return fakeQb;
      }),
      orderBy: jest.fn().mockReturnThis(),
      take: jest.fn().mockReturnThis(),
      getMany: jest.fn().mockResolvedValue([]),
    };
    const conversations = {
      findOneBy: jest
        .fn()
        .mockResolvedValue({ id: 10, userAId: 32, userBId: 33 }),
    };
    const messages = { createQueryBuilder: jest.fn().mockReturnValue(fakeQb) };
    const blocks = {
      status: jest
        .fn()
        .mockResolvedValue({ blockedByMe: false, blockedByPeer: false }),
    };
    return new ChatService(
      conversations as any,
      messages as any,
      {} as any,
      {} as any,
      {} as any,
      blocks as any,
      {} as any,
    );
  }

  it('删除过滤条件带括号，防止 OR 优先级绕过会话过滤', async () => {
    const andWhereCalls: string[] = [];
    const service = buildService(andWhereCalls);

    await service.getMessages(33, 10);

    // 不加括号会生成 (conversationId = ? AND ms.id IS NULL) OR deletedAt IS NULL，
    // 导致其他会话的消息也全部返回；必须为 OR 整体加括号。
    expect(andWhereCalls).toContain('(ms.id IS NULL OR ms.deletedAt IS NULL)');
    expect(
      andWhereCalls.some(
        (c) => c.includes('deletedAt IS NULL') && !c.includes('('),
      ),
    ).toBe(false);
  });

  it('对方拉黑我后发送消息被拒绝', async () => {
    const conversations = {
      findOneBy: jest.fn().mockResolvedValue({
        id: 10,
        userAId: 32,
        userBId: 33,
      }),
    };
    const users = {
      findOneBy: jest.fn().mockResolvedValue({ id: 33, isBanned: false }),
    };
    const blocks = {
      status: jest
        .fn()
        .mockResolvedValue({ blockedByMe: false, blockedByPeer: true }),
    };
    const follows = { isMutual: jest.fn().mockResolvedValue(true) };
    const messages = {
      count: jest.fn(),
      save: jest.fn(),
      create: jest.fn(),
    };
    const service = new ChatService(
      conversations as any,
      messages as any,
      {} as any,
      users as any,
      follows as any,
      blocks as any,
      {} as any,
    );

    await expect(service.sendMessage(32, 10, 'text', 'hello')).rejects.toThrow(
      '对方已把你拉黑',
    );
    expect(blocks.status).toHaveBeenCalledWith(32, 33);
  });
});
